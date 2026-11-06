#!/usr/bin/env bash
# Build a delivery zip from the committed HEAD and verify its contents.
# Usage: bash .claude/skills/zip-deliver/scripts/make_zip.sh [project_name]
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

NAME="${1:-$(basename "$ROOT")}"
DATE="$(date +%Y%m%d)"
OUT_DIR="$ROOT/dist"
mkdir -p "$OUT_DIR"

# 1. Refuse to build with uncommitted changes (git archive only sees commits).
if [ -n "$(git status --porcelain -- . ':!dist')" ]; then
  echo "ERROR: uncommitted changes exist. Commit them first:" >&2
  git status --short -- . ':!dist' >&2
  exit 1
fi

# 2. Pick the next version number for today.
N=1
while [ -e "$OUT_DIR/${NAME}_${DATE}_v${N}.zip" ]; do N=$((N + 1)); done
ZIP="$OUT_DIR/${NAME}_${DATE}_v${N}.zip"

git archive --format=zip --prefix="${NAME}/" -o "$ZIP" HEAD

# 3. Check for files that must never ship.
FORBIDDEN='(^|/)\.env$|\.(bin|safetensors|pt|pth|ckpt|gguf|onnx)$|(^|/)(\.venv|venv|__pycache__|node_modules|\.ipynb_checkpoints|wandb)/|\.pyc$|\.DS_Store$'
BAD="$(unzip -Z1 "$ZIP" | grep -E "$FORBIDDEN" || true)"
if [ -n "$BAD" ]; then
  echo "ERROR: forbidden files found in zip:" >&2
  echo "$BAD" >&2
  rm -f "$ZIP"
  exit 1
fi

# 4. Make sure it extracts cleanly into an empty directory.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
unzip -q "$ZIP" -d "$TMP"
[ -d "$TMP/$NAME" ] || { echo "ERROR: top-level folder $NAME missing" >&2; exit 1; }

# 5. Report.
echo "=== contents ==="
unzip -Z1 "$ZIP" | grep -v '/$'
echo "=== summary ==="
echo "zip:    $ZIP"
echo "size:   $(du -h "$ZIP" | cut -f1)"
echo "files:  $(unzip -Z1 "$ZIP" | grep -vc '/$')"
echo "commit: $(git rev-parse --short HEAD)"
