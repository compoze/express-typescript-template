#!/usr/bin/env bash

set -euo pipefail

APP_NAME=$1
ENV=$2

if [ "$ENV" != "dev" ] && [ "$ENV" != "stage" ] && [ "$ENV" != "prod" ]
then
    echo "$ENV is not a valid environment, must be either dev, stage, or prod"
    exit 1
else 
    echo "Deploying to $ENV..."
fi

gem install dpl

dpl --provider=heroku --app="$APP_NAME-$ENV" --api-key=$HEROKU_API_KEY