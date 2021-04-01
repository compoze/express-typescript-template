#!/usr/bin/env bash

set -euo pipefail

restart() {

    SERVICE=$1
    STAGE=$2
    echo "creating deployment for ${SERVICE}-${STAGE}"

    aws ecs update-service --cluster ${SERVICE}-${STAGE} --service ${SERVICE} --force-new-deployment
    
}
