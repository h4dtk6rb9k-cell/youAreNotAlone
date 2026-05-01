#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQUEST_FILE="${PROJECT_DIR}/tmp/screenshot_request"
STATUS_FILE="${PROJECT_DIR}/tmp/screenshot_status"
READY_FILE="${PROJECT_DIR}/tmp/screenshot_agent_ready"
HEARTBEAT_FILE="${PROJECT_DIR}/tmp/screenshot_agent_heartbeat"
SCREENSHOT_FILE="${PROJECT_DIR}/docs/reference/current_level_screenshot.png"
TIMEOUT_SECONDS="${1:-45}"

mkdir -p "${PROJECT_DIR}/tmp"
rm -f "${STATUS_FILE}"

if [[ ! -f "${READY_FILE}" ]]; then
  echo "Screenshot capture agent is not ready." >&2
  echo "Start tools/screenshot_capture_agent.command outside the Codex sandbox and leave it open." >&2
  exit 1
fi

touch "${REQUEST_FILE}"

start_time="$(date +%s)"

while true; do
  if [[ -f "${STATUS_FILE}" ]]; then
    status="$(cat "${STATUS_FILE}")"
    if [[ "${status}" == ok* ]]; then
      echo "Screenshot ready: ${SCREENSHOT_FILE}"
      exit 0
    fi
    echo "Screenshot failed: ${status}" >&2
    exit 1
  fi

  now="$(date +%s)"
  if [[ -f "${HEARTBEAT_FILE}" ]]; then
    heartbeat_time="$(stat -f '%m' "${HEARTBEAT_FILE}")"
    if (( now - heartbeat_time > 10 )); then
      echo "Screenshot capture agent heartbeat is stale." >&2
      echo "Restart tools/screenshot_capture_agent.command outside the Codex sandbox." >&2
      exit 1
    fi
  fi

  if (( now - start_time >= TIMEOUT_SECONDS )); then
    echo "Timed out waiting for screenshot capture agent." >&2
    echo "Start tools/screenshot_capture_agent.command outside the Codex sandbox." >&2
    exit 1
  fi

  sleep 1
done
