#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
INFRA_DIR="$PROJECT_DIR/infrastructure"

ENV=$1

if [[ -z "${ENV}" ]]; then
    echo "no environment provided"
    exit 1
else
    echo "Provisioning ECS infrastructure for environment ${ENV}"
    cd "$INFRA_DIR"
    make "init-$ENV"
fi
