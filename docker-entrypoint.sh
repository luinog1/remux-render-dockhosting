#!/bin/sh
set -eu

DATA_DIR="${DATA_DIR:-/data}"
DB_PATH="${DATA_DIR}/db.sqlite"
LOG_DIR="${DATA_DIR}/logs"
TORRENT_DIR="${DATA_DIR}/torrents"

# DockHosting/Coolify may inject its own DATABASE_URL when a database is linked.
# Remux's primary application database must remain the local persistent SQLite
# file under /data, matching the working Azure deployment.
export DATA_DIR
export DATABASE_URL="sqlite://${DB_PATH}?mode=rwc"
export LOG_FILE="${LOG_DIR}/remux.jsonl"
export TORRENT_DATA_DIR="${TORRENT_DIR}"

echo "[dockhosting-entrypoint] uid=$(id -u) gid=$(id -g)"
echo "[dockhosting-entrypoint] preparing DATA_DIR=${DATA_DIR}"
echo "[dockhosting-entrypoint] forcing DATABASE_URL=sqlite://${DB_PATH}?mode=rwc"

mkdir -p "${DATA_DIR}" "${LOG_DIR}" "${TORRENT_DIR}"

# DockHosting can mount a fresh volume with restrictive ownership. The Remux
# process runs inside this container and needs to create SQLite WAL/SHM files.
chmod 0777 "${DATA_DIR}" "${LOG_DIR}" "${TORRENT_DIR}" 2>/dev/null || true

if [ -e "${DB_PATH}" ]; then
  chmod 0666 "${DB_PATH}" 2>/dev/null || true
fi

PROBE="${DATA_DIR}/.remux-write-test"
if ! ( : > "${PROBE}" && rm -f "${PROBE}" ); then
  echo "[dockhosting-entrypoint] ERROR: ${DATA_DIR} is not writable." >&2
  echo "[dockhosting-entrypoint] Check the DockHosting persistent-volume mount and make sure it is mounted read/write at ${DATA_DIR}." >&2
  ls -ld "${DATA_DIR}" "${LOG_DIR}" "${TORRENT_DIR}" >&2 || true
  exit 70
fi

# Pre-create the SQLite database so an ownership/permission problem is exposed
# here instead of as SQLite code 14 later.
if [ ! -e "${DB_PATH}" ]; then
  : > "${DB_PATH}"
fi
chmod 0666 "${DB_PATH}" 2>/dev/null || true

echo "[dockhosting-entrypoint] data directory is writable"
ls -ld "${DATA_DIR}" "${LOG_DIR}" "${TORRENT_DIR}" || true
ls -l "${DB_PATH}" || true

exec /app/remux-server
