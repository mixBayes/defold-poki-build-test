#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

ROOT="."
OUTPUT="build/default"
BUNDLE_OUTPUT="dist"
PORT="17321"
STRICT_CONSOLE=0

usage() {
  cat <<'EOF'
Usage:
  run_all.sh [options]

Options:
  --root <dir>            Project root containing game.project (default: .)
  --output <dir>          Bob build output directory (default: build/default)
  --bundle-output <dir>   Bob bundle output directory (default: dist)
  --port <num>            HTTP port for Playwright smoke test (default: 17321)
  --strict-console        Fail if browser console has errors
  --help                  Show this help
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
    --port)
      PORT="${2:-}"
      shift 2
      ;;
    --strict-console)
      STRICT_CONSOLE=1
      shift
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

ROOT_ABS="$(cd "$ROOT" && pwd -P)"
if [[ ! -f "$ROOT_ABS/game.project" ]]; then
  echo "game.project not found under root: $ROOT_ABS" >&2
  exit 1
fi

detect_title() {
  awk -F'=' '
    /^\[project\]$/ { in_project=1; next }
    /^\[/ { if (in_project) exit }
    in_project && $1 ~ /^[[:space:]]*title[[:space:]]*$/ {
      value=$2
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      print value
      exit
    }
  ' "$ROOT_ABS/game.project"
}

TITLE="$(detect_title)"
if [[ -z "$TITLE" ]]; then
  echo "Cannot infer title from game.project." >&2
  exit 1
fi

BUNDLE_DIR="$BUNDLE_OUTPUT/$TITLE"

"$SCRIPT_DIR/build_defold.sh" \
  --root "$ROOT" \
  --output "$OUTPUT" \
  --bundle-output "$BUNDLE_OUTPUT" \
  --platform wasm-web \
  --architectures wasm-web

TEST_ARGS=(--root "$ROOT" --bundle-dir "$BUNDLE_DIR" --port "$PORT")
if [[ "$STRICT_CONSOLE" -eq 1 ]]; then
  TEST_ARGS+=(--strict-console)
fi

"$SCRIPT_DIR/test_playwright.sh" "${TEST_ARGS[@]}"
