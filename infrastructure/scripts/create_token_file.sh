#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

echo "credentials \"app.terraform.io\" {
  token = \"${TERRAFORM_TOKEN}\"
}" > "${ROOT_DIR}/.terraformrc"