#!/bin/sh

#
# Ensures that the project's network exists.
#
# The purpose of this script is to allow Docker scripts that need a network to
# leverage this script to ensure that the network exists before attempting to
# connect to it.
#

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

. "${ROOT}"/.env

if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(basename $ROOT | tr '[:upper:]' '[:lower:]' | sed "s/[^[:alpha:]-]//g")
fi
if [ -z "$NETWORK_NAME" ]; then
    NETWORK_NAME=${PROJECT_NAME}_default
fi

export PROJECT_NAME="${PROJECT_NAME}"
export NETWORK_NAME="${NETWORK_NAME}"

# Ensure Docker network exists (needed to run composer in php container)
if [ `docker network ls | grep "${NETWORK_NAME}" | wc -l | awk '{print $1}'` == 0 ]; then
    docker network create "${NETWORK_NAME}"
fi
