#!/bin/sh -eu

log() {
  printf "*** %s\n" "$@" >&2
}

CONVOY_VFS_PATH=/data
DOCKER_PLUGINS_DIR=/etc/docker/plugins
DOCKER_PLUGINS_SPEC="${DOCKER_PLUGINS_DIR}"/convoy.spec
RUN_CONVOY_DIR=/run/convoy

if [ ! -d "${DOCKER_PLUGINS_DIR}" ]; then
  log "Missing '-v ${DOCKER_PLUGINS_DIR}:${DOCKER_PLUGINS_DIR}'"
  exit 1
fi

if [ ! -d "${RUN_CONVOY_DIR}" ]; then
  log "Missing '-v ${RUN_CONVOY_DIR}:${RUN_CONVOY_DIR}'"
  exit 2
fi

if [ ! -d "${CONVOY_VFS_PATH}" ]; then
  log \
    "Missing '-v NFS_DATA_VOL:${CONVOY_VFS_PATH}'" \
    "See: https://docs.docker.com/storage/volumes/#create-a-service-which-creates-an-nfs-volume"
  exit 3
fi

if [ ! -f "${DOCKER_PLUGINS_SPEC}" ]; then
  echo "unix:///var/run/convoy/convoy.sock" >"${DOCKER_PLUGINS_SPEC}"
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
