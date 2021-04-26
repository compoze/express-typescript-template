#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

ENV=$1

echo "clearing existing auto tfvars"
rm -f *.auto.tfvars

echo "$(<${ROOT_DIR}/$ENV.tfvars)" > "${ROOT_DIR}/$ENV.auto.tfvars"