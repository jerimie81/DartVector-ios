#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
WEB_APP_ROOT="${DARTVECTOR_WEB_ROOT:-$PROJECT_ROOT/../DartVector}"
TARGET_DIR="$PROJECT_ROOT/DartVector/WebAssets"

if [[ ! -d "$WEB_APP_ROOT" ]]; then
  echo "Error: web app source not found at $WEB_APP_ROOT" >&2
  exit 1
fi

if [[ ! -d "$WEB_APP_ROOT/out" ]]; then
  echo "Error: static export directory not found at $WEB_APP_ROOT/out" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
find "$TARGET_DIR" -mindepth 1 -maxdepth 1 ! -name ".gitkeep" -exec rm -rf {} +
cp -R "$WEB_APP_ROOT/out/." "$TARGET_DIR/"
if [[ ! -f "$TARGET_DIR/.gitkeep" ]]; then
  touch "$TARGET_DIR/.gitkeep"
fi

if [[ ! -f "$TARGET_DIR/index.html" ]]; then
  echo "Error: expected index.html to exist in $TARGET_DIR" >&2
  exit 1
fi

echo "Synced web assets from $WEB_APP_ROOT/out to $TARGET_DIR"
