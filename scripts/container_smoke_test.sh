#!/usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=$1
APP_VERSION=$2

docker run --name $CONTAINER_NAME -dit -p 5000:5000 $CONTAINER_NAME:$APP_VERSION

. ./scripts/test_up_status.sh

test_server localhost

docker rm $CONTAINER_NAME -f
