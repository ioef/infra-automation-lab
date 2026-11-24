#!/usr/bin/env sh
set -eu

LOG_DIR="${LOG_DIR:-/var/log}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/application.log}"
RETENTION_DAYS="${RETENTION_DAYS:-5}"

# Check directory and permissions
if [ ! -d "$LOG_DIR" ] || [ ! -r "$LOG_DIR" ] || [ ! -w "$LOG_DIR" ] || [ ! -x "$LOG_DIR" ]; then
  echo "ERROR: Log directory '$LOG_DIR' is missing or not accessible." >&2
  exit 1
fi

# Exit cleanly if the log file does not exist yet
if [ ! -e "$LOG_FILE" ]; then
  echo "INFO: '$LOG_FILE' not found. Nothing to rotate."
  exit 0
fi

if [ ! -r "$LOG_FILE" ] || [ ! -w "$LOG_FILE" ]; then
  echo "ERROR: Insufficient permissions on '$LOG_FILE'." >&2
  exit 1
fi

# Rotate and compress if non-empty (copy + truncate keeps active writer working)
if [ -s "$LOG_FILE" ]; then
  STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
  ARCHIVE="${LOG_FILE%.log}-$STAMP.log.gz"
  BEFORE=$(wc -c < "$LOG_FILE" | tr -d ' ')

  cp "$LOG_FILE" "${LOG_FILE%.log}-$STAMP.log"
  : > "$LOG_FILE"
  gzip -f "${LOG_FILE%.log}-$STAMP.log"

  AFTER=$(wc -c < "$ARCHIVE" | tr -d ' ')
  echo "INFO: Rotated '$LOG_FILE' -> '$ARCHIVE' (${BEFORE}B -> ${AFTER}B)"
else
  echo "INFO: '$LOG_FILE' is empty. Skipping rotation."
fi

# Delete compressed archives older than 5 days
DELETED=$(find "$LOG_DIR" -maxdepth 1 -type f -name "application-*.log.gz" -mtime "+$RETENTION_DAYS" -print -delete | wc -l | tr -d ' ')
echo "INFO: Retention=${RETENTION_DAYS}d, deleted=${DELETED} old archive(s)."
