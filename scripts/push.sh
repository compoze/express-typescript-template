#!/usr/bin/env bash

set -euo pipefail

push() {

    AWS_ACCOUNT_ID=$1
    REGION=$2
    CONTAINER=$3
    TAG=$4

    REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${CONTAINER}:${TAG}"
    echo "pushing $REPOSITORY ..."
    docker push "$REPOSITORY"
}
