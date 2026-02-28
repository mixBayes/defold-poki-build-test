#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

ROOT="."
OUTPUT="build/default"
BUNDLE_OUTPUT="dist"
PLATFORM="wasm-web"
ARCHITECTURES="wasm-web"

usage() {
  cat <<'EOF'
Usage:
  build_defold.sh [options]

Options:
  --root <dir>            Project root containing game.project (default: .)
  --output <dir>          Bob build output directory (default: build/default)
  --bundle-output <dir>   Bob bundle output directory (default: dist)
  --platform <name>       Defold platform (default: wasm-web)
  --architectures <list>  Defold architectures list (default: wasm-web)
  --help                  Show this help

Environment:
  DEFOLD_JAVA_BIN         Override java binary used for Bob
  DEFOLD_BOB_JAR          Override Bob jar path
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT="${2:-}"
      shift 2
      ;;
    --bundle-output)
      BUNDLE_OUTPUT="${2:-}"
      shift 2
      ;;
    --platform)
      PLATFORM="${2:-}"
      shift 2
      ;;
    --architectures)
      ARCHITECTURES="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$ROOT" || -z "$OUTPUT" || -z "$BUNDLE_OUTPUT" || -z "$PLATFORM" || -z "$ARCHITECTURES" ]]; then
  echo "Invalid empty argument." >&2
  usage
  exit 2
fi

ROOT_ABS="$(cd "$ROOT" && pwd -P)"
if [[ ! -f "$ROOT_ABS/game.project" ]]; then
  echo "game.project not found under root: $ROOT_ABS" >&2
  exit 1
fi

if [[ "$OUTPUT" = /* ]]; then
  echo "--output must be relative to --root. Received absolute path: $OUTPUT" >&2
  exit 1
fi

resolve_path() {
  local path_value="$1"
  if [[ "$path_value" = /* ]]; then
    printf '%s\n' "$path_value"
  else
    printf '%s\n' "$ROOT_ABS/$path_value"
  fi
}

canonicalize_existing_or_parent() {
  local raw="$1"
  if [[ -e "$raw" ]]; then
    (cd "$raw" && pwd -P)
  else
    mkdir -p "$(dirname "$raw")"
    local parent
    parent="$(cd "$(dirname "$raw")" && pwd -P)"
    printf '%s/%s\n' "$parent" "$(basename "$raw")"
  fi
}

OUTPUT_ABS_RAW="$(resolve_path "$OUTPUT")"
BUNDLE_ABS_RAW="$(resolve_path "$BUNDLE_OUTPUT")"
OUTPUT_ABS="$(canonicalize_existing_or_parent "$OUTPUT_ABS_RAW")"
BUNDLE_ABS="$(canonicalize_existing_or_parent "$BUNDLE_ABS_RAW")"

if [[ "$BUNDLE_ABS" == "$ROOT_ABS/build" || "$BUNDLE_ABS" == "$ROOT_ABS/build/"* ]]; then
  echo "Bundle output cannot be inside '$ROOT_ABS/build' because Defold reserves this folder." >&2
  exit 1
fi

detect_bob_jar() {
  if [[ -n "${DEFOLD_BOB_JAR:-}" ]]; then
    if [[ -f "$DEFOLD_BOB_JAR" ]]; then
      printf '%s\n' "$DEFOLD_BOB_JAR"
      return 0
    fi
    echo "DEFOLD_BOB_JAR does not exist: $DEFOLD_BOB_JAR" >&2
    return 1
  fi

  local jar
  jar="$(ls -1 /Applications/Defold.app/Contents/Resources/packages/defold-*.jar 2>/dev/null | head -n 1 || true)"
  if [[ -n "$jar" && -f "$jar" ]]; then
    printf '%s\n' "$jar"
    return 0
  fi

  return 1
}

detect_java_bin() {
  if [[ -n "${DEFOLD_JAVA_BIN:-}" ]]; then
    if [[ -x "$DEFOLD_JAVA_BIN" ]]; then
      printf '%s\n' "$DEFOLD_JAVA_BIN"
      return 0
    fi
    echo "DEFOLD_JAVA_BIN is not executable: $DEFOLD_JAVA_BIN" >&2
    return 1
  fi

  local jdk_bin
  jdk_bin="$(ls -1 /Applications/Defold.app/Contents/Resources/packages/jdk-*/bin/java 2>/dev/null | head -n 1 || true)"
  if [[ -n "$jdk_bin" && -x "$jdk_bin" ]]; then
    printf '%s\n' "$jdk_bin"
    return 0
  fi

  if command -v java >/dev/null 2>&1; then
    command -v java
    return 0
  fi

  return 1
}

BOB_JAR="$(detect_bob_jar || true)"
JAVA_BIN="$(detect_java_bin || true)"

if [[ -z "$BOB_JAR" ]]; then
  echo "Cannot locate Bob jar. Set DEFOLD_BOB_JAR or install Defold.app." >&2
  exit 1
fi

if [[ -z "$JAVA_BIN" ]]; then
  echo "Cannot locate java binary. Set DEFOLD_JAVA_BIN or install Java/Defold JDK." >&2
  exit 1
fi

echo "[build] root=$ROOT_ABS"
echo "[build] output=$OUTPUT_ABS"
echo "[build] bundle_output=$BUNDLE_ABS"
echo "[build] java=$JAVA_BIN"
echo "[build] bob_jar=$BOB_JAR"
echo "[build] platform=$PLATFORM architectures=$ARCHITECTURES"

"$JAVA_BIN" -cp "$BOB_JAR" com.dynamo.bob.Bob \
  --root "$ROOT_ABS" \
  --output "$OUTPUT" \
  --bundle-output "$BUNDLE_OUTPUT" \
  --platform "$PLATFORM" \
  --architectures "$ARCHITECTURES" \
  --archive \
  resolve build bundle

echo "[build] done"
