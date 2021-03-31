#!/usr/bin/env bash

set -euo pipefail

APP_NAME=$1
TAG=$2


echo "installing dependencies"
npm ci
echo "building ${APP_NAME}:${TAG}"
npm run build:app
docker build . -t "${APP_NAME}:${TAG}"
