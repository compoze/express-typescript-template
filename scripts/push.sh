#!/usr/bin/env bash

set -euo pipefail

push() {

    AWS_ACCOUNT_ID=$1
    REGION=$2
    CONTAINER=$3
    TAG=$4
    ENV=$5

    IMAGE="${CONTAINER}:${TAG}"
    REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ENV}/${CONTAINER}:${TAG}"

    echo "retagging image ${IMAGE} for registry ${REPOSITORY}"
    docker tag "${IMAGE}" "${REPOSITORY}"
    echo "pushing $REPOSITORY ..."
    docker push "$REPOSITORY"
}
