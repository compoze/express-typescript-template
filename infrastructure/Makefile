.SHELL := /usr/bin/bash
.PHONY: check-workspace check-run-deps check-install-deps install prod staging qa dev testing plan apply destroy

TF_VERSION := 0.14.7
OS_NAME=$(shell uname -s | tr '[:upper:]' '[:lower:]')
WORSPACE=$(shell jq -r .backend.config.workspaces.name .terraform/terraform.tfstate 2>/dev/null)
ENVIRONMENT=$(shell echo $(WORSPACE) | sed -E s'/.*-(.*)/\1/')
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)
TF_FILENAME := terraform_$(TF_VERSION)_$(OS_NAME)_amd64.zip
TF_LINK := https://releases.hashicorp.com/terraform/$(TF_VERSION)/$(TF_FILENAME)

init-dev: generate-token-file dev apply

init-stage: generate-token-file stage apply

init-prod: generate-token-file prod apply

default: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check-workspace: check-run-deps
	@if [ ! -f .terraform/terraform.tfstate ]; then \
	  echo "$(BOLD)$(RED)Aborting - workspace not selected $(RESET)"; \
	  echo "$(YELLOW)Run $(BOLD)make <workspace> $(RESET)$(YELLOW)Where <workspace> is qa, staging or prod.$(RESET)"; \
	  exit 1; \
	fi

check-run-deps:
	@if ! jq -h > /dev/null 2>&1; then \
	  echo "$(BOLD)$(RED)Aborting - jq is required$(RESET)"; \
	  exit 1; \
	fi
	@if ! terraform -help >/dev/null 2>&1; then \
	  echo "$(BOLD)$(RED)Aborting - terraform is required$(RESET)"; \
      echo "$(YELLOW)Run $(BOLD)make install$(RESET)"; \
	  exit 1; \
	fi

check-install-deps:
	@if ! unzip -h >/dev/null 2>&1; then \
	  echo "$(BOLD)$(RED)Aborting - unzip is required$(RESET)"; \
	  exit 1; \
	fi
	@if ! curl -h > /dev/null 2>&1; then \
	  echo "$(BOLD)$(RED)Aborting - curl is required$(RESET)"; \
	  exit 1; \
	fi

install: check-install-deps ## Download and install terraform in /usr/local/bin/terraform. Should work on Linux, MacOS and WSL
	@rm -f /tmp/$(TF_FILENAME) /tmp/terraform
	curl -s -o /tmp/$(TF_FILENAME) $(TF_LINK)
	@unzip /tmp/$(TF_FILENAME) -d /tmp
	@rm -f /tmp/$(TF_FILENAME)
	@sudo mv -f -v /tmp/terraform /usr/local/bin/terraform
	@terraform -version

dev: check-run-deps ## Select the dev workspace.
	@if [ "$(ENVIRONMENT)" != "dev" ]; then \
		terraform init -backend-config=dev.hcl -reconfigure; \
	else \
		echo "$(BOLD)$(GREEN)dev workspace selected$(RESET)"; \
	fi

prod: check-run-deps ## Select the production workspace.
	@if [ "$(ENVIRONMENT)" != "prod" ]; then \
		terraform init -backend-config=prod.hcl -reconfigure; \
	else \
		echo "$(BOLD)$(GREEN)prod workspace selected$(RESET)"; \
	fi

stage: check-run-deps ## Select the stage workspace
	@if [ "$(ENVIRONMENT)" != "stage" ]; then \
		terraform init -backend-config=stage.hcl -reconfigure; \
	else \
		echo "$(BOLD)$(GREEN)stage workspace selected$(RESET)"; \
	fi

qa: check-run-deps ## Select the qa workspace
	@if [ "$(ENVIRONMENT)" != "qa" ]; then \
		terraform init -backend-config=qa.hcl -reconfigure; \
	else \
		echo "$(BOLD)$(GREEN)qa workspace selected$(RESET)"; \
	fi

plan: check-workspace ## Show terraform plan for the current workspace.
	@terraform plan

apply: check-workspace ## Show terraform cloud url
	@terraform apply -auto-approve
	@echo "$(BOLD)$(GREEN)Visit https://app.terraform.io/app/test-org-compoze/workspaces/$(WORSPACE)/ to check available plans.$(RESET)"; \
