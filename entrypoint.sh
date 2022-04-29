#!/usr/bin/env bash

set -e

if [ ! -z $USER_ID ]; then
  echo "Starting with UID: $USER_ID"
  CONTAINER_USER=runner
  addgroup --gid "${USER_ID}" ${CONTAINER_USER}
  adduser -s /bin/bash -u "${USER_ID}" -G "${CONTAINER_USER}" -D "${CONTAINER_USER}"
  sudo --preserve-env --user "${CONTAINER_USER}" /create_pull_request.sh
else
  /create_pull_request.sh
fi
