#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${PROJECT_DIR}"

echo "Still City screenshot capture"
echo "Project: ${PROJECT_DIR}"
echo

"${SCRIPT_DIR}/capture_level_screenshot.sh"

echo
echo "Screenshot saved to:"
echo "${PROJECT_DIR}/docs/reference/current_level_screenshot.png"
echo
echo "You can close this window."
