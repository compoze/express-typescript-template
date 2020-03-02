#!/usr/bin/env bash

set -euo pipefail

dpl --provider=heroku --app=$APP_NAME --api-key=$HEROKU_API_KEY