#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REQUEST_FILE="${PROJECT_DIR}/tmp/screenshot_request"
STATUS_FILE="${PROJECT_DIR}/tmp/screenshot_status"
STOP_FILE="${PROJECT_DIR}/tmp/screenshot_agent_stop"
READY_FILE="${PROJECT_DIR}/tmp/screenshot_agent_ready"
HEARTBEAT_FILE="${PROJECT_DIR}/tmp/screenshot_agent_heartbeat"
LOG_FILE="${PROJECT_DIR}/tmp/screenshot_agent.log"

mkdir -p "${PROJECT_DIR}/tmp"
rm -f "${STOP_FILE}"
echo "ready $(date '+%Y-%m-%d %H:%M:%S')" > "${READY_FILE}"
echo "start $(date '+%Y-%m-%d %H:%M:%S')" > "${LOG_FILE}"

cleanup() {
  rm -f "${READY_FILE}" "${HEARTBEAT_FILE}"
}
trap cleanup EXIT INT TERM

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
  echo "alive $(date '+%Y-%m-%d %H:%M:%S')" > "${HEARTBEAT_FILE}"

  if [[ -f "${STOP_FILE}" ]]; then
    echo "Stop requested."
    echo "stop $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
    rm -f "${STOP_FILE}"
    exit 0
  fi

  if [[ -f "${REQUEST_FILE}" ]]; then
    rm -f "${REQUEST_FILE}"
    echo "[$(date '+%H:%M:%S')] Screenshot requested."
    echo "request $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
    if "${SCRIPT_DIR}/capture_level_screenshot.sh"; then
      echo "ok $(date '+%Y-%m-%d %H:%M:%S')" > "${STATUS_FILE}"
      echo "[$(date '+%H:%M:%S')] Screenshot saved."
      echo "ok $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
    else
      echo "fail $(date '+%Y-%m-%d %H:%M:%S')" > "${STATUS_FILE}"
      echo "[$(date '+%H:%M:%S')] Screenshot failed."
      echo "fail $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
    fi
  fi

  sleep 1
done
