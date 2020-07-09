#! /usr/bin/env sh

set -eu pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."

echo "logging into Heroku..."
docker login --username=_ --password=$HEROKU_API_KEY registry.heroku.com

echo "building latest image..."
docker build -t  "registry.heroku.com/$APP_NAME/web" .

echo "Pushing registry.heroku.com/$APP_NAME/web to heroku registry"
docker push "registry.heroku.com/$APP_NAME/web"

echo "Creating release..."
heroku container:release web --app $APP_NAME