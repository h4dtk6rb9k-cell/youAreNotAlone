#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
GODOT_APP="${GODOT_APP:-/Applications/Godot.app}"

if "${GODOT_BIN}" \
  --path "${PROJECT_DIR}" \
  --capture-screenshot \
  --screenshot-output=res://docs/reference/current_level_screenshot.png
then
  exit 0
fi

open -W -n "${GODOT_APP}" --args \
  --path "${PROJECT_DIR}" \
  --capture-screenshot \
  --screenshot-output=res://docs/reference/current_level_screenshot.png
