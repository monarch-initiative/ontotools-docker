#!/bin/sh
# Wrapper script for docker.

set -eu
cd "$(dirname "$0")"

# Use a TTY only if stdin AND stdout are terminals.
TTY_FLAGS=""
if [ -t 0 ] && [ -t 1 ]; then
  TTY_FLAGS="-it"
fi

# Ensure Docker sees the repo folder you’re in
docker run $TTY_FLAGS --rm \
  -v $PWD/:/work -w /work \
  -e ROBOT_JAVA_ARGS='-Xmx4G' \
  -e JAVA_OPTS='-Xmx4G' \
  obolibrary/odkfull:v1.6 "$@"
