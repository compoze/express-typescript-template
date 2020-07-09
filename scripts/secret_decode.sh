#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
CONFIG_DIR="$SCRIPT_DIR/../config"

if [[ -z "${AUTH_CONFIG}" ]]; then
  echo "$(tput setaf 1)No firebase config found..."
  echo "$(tput setaf 6)Please download the service account from $(tput sgr0)https://console.firebase.google.com/u/0/project/myapp/settings/serviceaccounts/adminsdk"
  echo "$(tput setaf 6)and save it in the root directory as firebase-admin-sdk.json"
  echo "$(tput setaf 3)Please ensure that it does not get checked into version control$(tput sgr0)"
else
  rm -rf "$CONFIG_DIR"
  mkdir "$CONFIG_DIR"
  echo "Firebase config found, decoding configuration..."
  echo "${AUTH_CONFIG}" | base64 --decode >"$CONFIG_DIR/spawn-platform.json"
fi
