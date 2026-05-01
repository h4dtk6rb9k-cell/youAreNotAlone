#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REQUEST_FILE="${PROJECT_DIR}/tmp/screenshot_request"
STATUS_FILE="${PROJECT_DIR}/tmp/screenshot_status"
STOP_FILE="${PROJECT_DIR}/tmp/screenshot_agent_stop"

mkdir -p "${PROJECT_DIR}/tmp"
rm -f "${STOP_FILE}"

echo "Still City screenshot capture agent"
echo "Project: ${PROJECT_DIR}"
echo
echo "Leave this window open while Codex is working."
echo "Codex can request screenshots by writing:"
echo "${REQUEST_FILE}"
echo
echo "To stop: close this window or create:"
echo "${STOP_FILE}"
echo

while true; do
  if [[ -f "${STOP_FILE}" ]]; then
    echo "Stop requested."
    rm -f "${STOP_FILE}"
    exit 0
  fi

  if [[ -f "${REQUEST_FILE}" ]]; then
    rm -f "${REQUEST_FILE}"
    echo "[$(date '+%H:%M:%S')] Screenshot requested."
    if "${SCRIPT_DIR}/capture_level_screenshot.sh"; then
      echo "ok $(date '+%Y-%m-%d %H:%M:%S')" > "${STATUS_FILE}"
      echo "[$(date '+%H:%M:%S')] Screenshot saved."
    else
      echo "fail $(date '+%Y-%m-%d %H:%M:%S')" > "${STATUS_FILE}"
      echo "[$(date '+%H:%M:%S')] Screenshot failed."
    fi
  fi

  sleep 1
done
