#!/usr/bin/env bash

set -euo pipefail

AWS_ACCOUNT_ID=$1
REGION=$2
CONTAINER=$3
TAG=$4
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${CONTAINER}:${TAG}"
