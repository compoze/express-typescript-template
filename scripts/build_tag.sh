#!/usr/bin/env bash

set -euo pipefail
IMAGE=$1
TAG=$2

echo "building ${IMAGE}:${TAG}"
npm run build:app
docker build . -t "${IMAGE}:${TAG}"
