#!/usr/bin/env bash
set -euo pipefail

ROOT="."
BUNDLE_DIR=""
HOST="localhost"
PORT="17321"
OUTPUT_DIR="output/playwright"
STRICT_CONSOLE=0

usage() {
  cat <<'EOF'
Usage:
  test_playwright.sh [options]

Options:
  --root <dir>            Project root containing game.project (default: .)
  --bundle-dir <dir>      Folder containing index.html (default: dist/<project-title>)
  --host <ip>             HTTP bind host (default: localhost)
  --port <num>            HTTP port (default: 17321)
  --output-dir <dir>      Artifact output directory (default: output/playwright)
  --strict-console        Fail if Playwright console error count > 0
  --help                  Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT="${2:-}"
      shift 2
      ;;
    --bundle-dir)
      BUNDLE_DIR="${2:-}"
      shift 2
      ;;
    --host)
      HOST="${2:-}"
      shift 2
      ;;
    --port)
      PORT="${2:-}"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="${2:-}"
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

if [[ -z "$ROOT" || -z "$HOST" || -z "$PORT" || -z "$OUTPUT_DIR" ]]; then
  echo "Invalid empty argument." >&2
  usage
  exit 2
fi

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

if [[ -z "$BUNDLE_DIR" ]]; then
  TITLE="$(detect_title)"
  if [[ -z "$TITLE" ]]; then
    echo "Cannot infer project title from game.project; pass --bundle-dir explicitly." >&2
    exit 1
  fi
  BUNDLE_DIR="dist/$TITLE"
fi

if [[ "$BUNDLE_DIR" = /* ]]; then
  BUNDLE_ABS="$BUNDLE_DIR"
else
  BUNDLE_ABS="$ROOT_ABS/$BUNDLE_DIR"
fi

INDEX_HTML="$BUNDLE_ABS/index.html"
if [[ ! -f "$INDEX_HTML" ]]; then
  echo "Bundle index not found: $INDEX_HTML" >&2
  exit 1
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found. Install Node.js/npm first." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. It is required for local static serving." >&2
  exit 1
fi

PWCLI=(npx --yes --package @playwright/cli playwright-cli)

if [[ "$OUTPUT_DIR" = /* ]]; then
  OUTPUT_ABS="$OUTPUT_DIR"
else
  OUTPUT_ABS="$ROOT_ABS/$OUTPUT_DIR"
fi

RUN_ID="$(date +%Y%m%d-%H%M%S)"
ARTIFACT_DIR="$OUTPUT_ABS/$RUN_ID"
mkdir -p "$ARTIFACT_DIR"

SERVER_PID=""
cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" >/dev/null 2>&1 || true
  fi
  "${PWCLI[@]}" close-all >/dev/null 2>&1 || true
}
trap cleanup EXIT

HTTP_LOG="$ARTIFACT_DIR/http-server.log"
python3 -m http.server "$PORT" --bind "$HOST" --directory "$BUNDLE_ABS" >"$HTTP_LOG" 2>&1 &
SERVER_PID="$!"
sleep 1

URL="http://$HOST:$PORT/index.html"

set -x
"${PWCLI[@]}" open "$URL" | tee "$ARTIFACT_DIR/playwright-open.log"
"${PWCLI[@]}" snapshot | tee "$ARTIFACT_DIR/playwright-snapshot.log"
"${PWCLI[@]}" screenshot | tee "$ARTIFACT_DIR/playwright-screenshot.log"
"${PWCLI[@]}" console error | tee "$ARTIFACT_DIR/playwright-console.log"
set +x

LAST_SCREENSHOT="$(ls -1t "$ROOT_ABS/.playwright-cli"/page-*.png 2>/dev/null | head -n 1 || true)"
LAST_SNAPSHOT="$(ls -1t "$ROOT_ABS/.playwright-cli"/page-*.yml 2>/dev/null | head -n 1 || true)"
LAST_CONSOLE="$(ls -1t "$ROOT_ABS/.playwright-cli"/console-*.log 2>/dev/null | head -n 1 || true)"

if [[ -n "$LAST_SCREENSHOT" ]]; then
  cp "$LAST_SCREENSHOT" "$ARTIFACT_DIR/"
fi
if [[ -n "$LAST_SNAPSHOT" ]]; then
  cp "$LAST_SNAPSHOT" "$ARTIFACT_DIR/"
fi
if [[ -n "$LAST_CONSOLE" ]]; then
  cp "$LAST_CONSOLE" "$ARTIFACT_DIR/"
fi

ERROR_COUNT=0
if [[ -n "$LAST_CONSOLE" ]]; then
  ERROR_COUNT="$(grep -c '^\[ERROR\]' "$LAST_CONSOLE" || true)"
fi

echo "[test] url=$URL"
echo "[test] artifacts=$ARTIFACT_DIR"
echo "[test] console_errors=$ERROR_COUNT"

if [[ "$STRICT_CONSOLE" -eq 1 && "$ERROR_COUNT" -gt 0 ]]; then
  echo "Console errors detected and --strict-console is enabled." >&2
  exit 1
fi

echo "[test] done"
