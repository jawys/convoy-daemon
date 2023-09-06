#!/bin/sh -eu

log() {
  printf "*** %s\n" "$@" >&2
}

DOCKER_PLUGINS_DIR=/etc/docker/plugins

CONVOY_SOCKET_DIR=/run/docker/plugins/convoy
CONVOY_SPEC_FILE="${DOCKER_PLUGINS_DIR}"/convoy.spec
CONVOY_VFS_PATH=/data

if [ ! -d "${DOCKER_PLUGINS_DIR}" ]; then
  log "Missing '--volume ${DOCKER_PLUGINS_DIR}:${DOCKER_PLUGINS_DIR}'"
  exit 1
fi

if [ ! -d "${CONVOY_SOCKET_DIR}" ]; then
  log "Missing '--volume ${CONVOY_SOCKET_DIR}:${CONVOY_SOCKET_DIR}'"
  exit 2
fi

if [ ! -d "${CONVOY_VFS_PATH}" ]; then
  log \
    "Missing '--volume CONVOY_NFS_VOL:${CONVOY_VFS_PATH}'" \
    "See: https://docs.docker.com/storage/volumes/#create-a-service-which-creates-an-nfs-volume"
  exit 3
fi

if [ ! -f "${CONVOY_SPEC_FILE}" ]; then
  echo "unix://${CONVOY_SOCKET_DIR}/convoy.sock" >"${CONVOY_SPEC_FILE}"
fi

if [ $# -eq 0 ]; then
  # defaults
  set -- convoy daemon --drivers vfs --driver-opts vfs.path="${CONVOY_VFS_PATH}"
elif command -v "$1" >/dev/null; then
  # sh etc.
  set -- "$@"
else
  # subcommand
  set -- convoy "$@"
fi

exec "$@"
