CURL := $(shell which curl)
TERRAFORM ?= $(BUILD_HARNESS_PATH)/vendor/terraform
TERRAFORM_VER ?= 0.11.7
TERRAFORM_ARCH ?= $(BUILD_HARNESS_ARCH)
TERRAFORM_URL ?= https://releases.hashicorp.com/terraform/$(TERRAFORM_VER)/terraform_$(TERRAFORM_VER)_$(BUILD_HARNESS_OS)_$(TERRAFORM_ARCH).zip
TERRAFORM_DIR ?= $(PWD)
TERRAFORM_VARS_FILE ?=
TERRAFORM_OUTPUT_VAR ?=
TERRAFORM_OUTPUT_VALUE ?=
TERRAFORM_DATA_DIR ?= $(TERRAFORM_DIR)/.terraform
TERRAFORM_STATE_FILE ?= $(TERRAFORM_DIR)/terraform.tfstate
TERRAFORM_KEYPAIR_NAME ?= $(shell hostname)-build-harness-keypair

ifdef HAS_JOSH_K_SEAL_OF_APPROVAL
	TERRAFORM_KEYPAIR_NAME = travis-build-harness-keypair
endif

ifdef TERRAFORM_TRAVIS_KEYPAIR_OVERRIDE
	TERRAFORM_KEYPAIR_NAME = $(TERRAFORM_TRAVIS_KEYPAIR_OVERRIDE)
endif

TERRAFORM_FORCE_KEYPAIR_CREATION ?= 
TERRAFORM_EXPORTS = export TF_DATA_DIR=$(TERRAFORM_DATA_DIR)
ifndef TERRAFORM_FORCE_KEYPAIR_CREATION
	TERRAFORM_EXPORTS = export TF_DATA_DIR=$(TERRAFORM_DATA_DIR) export TF_VAR_keypair_name=$(TERRAFORM_KEYPAIR_NAME)
endif

TERRAFORM_STATE_ARTIFACTORY_TOKEN ?=
TERRAFORM_STATE_ARTIFACTORY_STAGE ?= scratch
TRAVIS_REPO_SLUG ?= $(GITHUB_USER)/local
TERRAFORM_STATE_ARTIFACTORY_URL ?= https://na.artifactory.swg-devops.com/artifactory/hyc-cloud-private-$(TERRAFORM_STATE_ARTIFACTORY_STAGE)-generic-local/states/$(TRAVIS_REPO_SLUG)
TERRAFORM_STATE_ARTIFACTORY_ARCHIVE ?= $(shell echo $(TERRAFORM_DIR) | sed 's/\.//g').tar.gz

.PHONY: terraform\:install
## Install terraform version required based on TERRAFORM_STATE_FILE or alternatively from TERRAFORM_VER
terraform\:install:
	$(eval TERRAFORM_TFSTATE_VER := $(shell cat $(TERRAFORM_STATE_FILE) 2> /dev/null | $(SELF) jq:search JQ_SEARCH_VAR=.terraform_version))
	$(eval TERRAFORM_VER := $(if $(TERRAFORM_TFSTATE_VER),$(TERRAFORM_TFSTATE_VER),$(TERRAFORM_VER)))
	@[[ $(TERRAFORM)-$(TERRAFORM_VER) -ef $(TERRAFORM) && -x $(TERRAFORM)-$(TERRAFORM_VER) ]] || ( \
		echo "Installing Terraform $(TERRAFORM_VER) ($(BUILD_HARNESS_OS)) from $(TERRAFORM_URL)" && \
		curl '-#' -fL -o $(TMP)/terraform.zip $(TERRAFORM_URL) && \
		unzip -q -d $(TMP)/ $(TMP)/terraform.zip && \
		mv $(TMP)/terraform $(TERRAFORM)-$(TERRAFORM_VER) && \
		ln -s -f $(TERRAFORM)-$(TERRAFORM_VER) $(TERRAFORM) && \
		rm -f $(TMP)/terraform.zip \
		)
	$(TERRAFORM) version

## Ensure all plugins can be fetched
terraform\:get-plugins: %get-plugins: %install 
	@$(TERRAFORM_EXPORTS); $(TERRAFORM) init -get-plugins -backend=false -input=false $(TERRAFORM_DIR) >/dev/null

## Ensure all modules can be fetched
terraform\:get-modules: %get-modules: %install
	@$(TERRAFORM_EXPORTS); $(TERRAFORM) init -get -backend=false -input=false $(TERRAFORM_DIR) >/dev/null

## Basic terraform sanity check
terraform\:validate: %validate: %install
# We only want to run validate on terraform versions like *.11.*, so check for that
ifeq ($(shell echo $(TERRAFORM_VER) | cut -f2 -d.),11)
	@$(TERRAFORM_EXPORTS); $(TERRAFORM) validate -check-variables=false -var-file="$(TERRAFORM_VARS_FILE)" $(TERRAFORM_DIR)
endif

## Lint check Terraform
terraform\:lint: %lint: %install
	@FAIL=`$(TERRAFORM) fmt -write=false | xargs --no-run-if-empty -n 1 printf '\t- %s\n'`; \
	[ -z "$$FAIL" ] || (echo "Terraform configuration needs linting. Run '$(TERRAFORM) fmt'"; echo $$FAIL; exit 1)

.PHONY: terraform\:apply
## Run terraform apply with -var-file (TERRAFORM_VARS_FILE) in dir (TERRAFORM_DIR)
terraform\:apply: %apply: %get-plugins %get-modules %validate
	@$(TERRAFORM_EXPORTS); $(TERRAFORM) apply -input=false -auto-approve -var-file="$(TERRAFORM_VARS_FILE)" -state="$(TERRAFORM_STATE_FILE)" $(TERRAFORM_DIR)

.PHONY: terraform\:destroy
## Destroy terraform resources
terraform\:destroy: %destroy: %get-plugins %get-modules
ifeq ($(shell test -d $(TERRAFORM_DIR) && echo -n yes),yes)
	@$(TERRAFORM_EXPORTS); $(TERRAFORM) destroy -input=false -force -var-file="$(TERRAFORM_VARS_FILE)" -state="$(TERRAFORM_STATE_FILE)" $(TERRAFORM_DIR)
endif

.PHONY: terraform\:output
## Print terraform output variable value
terraform\:output: %output:
	@$(TERRAFORM_EXPORTS); $(TERRAFORM) output -state="$(TERRAFORM_STATE_FILE)" $(TERRAFORM_OUTPUT_VAR)

.PHONY: terraform\:save-state
## Persist terraform state in artifactory
terraform\:save-state: %save-state:
	@echo "Saving archive file: $(TERRAFORM_STATE_ARTIFACTORY_URL)/$(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE)"
	$(eval TERRAFORM_STATE_CLUSTER_NAME := $(shell $(SELF) terraform:output TERRAFORM_OUTPUT_VAR=cluster-name))
	@tar zcf $(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE) id_rsa id_rsa.pub $(TERRAFORM_VARS_FILE) $(TERRAFORM_DIR)/
	@curl -H "X-JFrog-Art-Api: $(TERRAFORM_STATE_ARTIFACTORY_TOKEN)" -X PUT -T $(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE) "$(TERRAFORM_STATE_ARTIFACTORY_URL)/$(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE);cluster-name=$(TERRAFORM_STATE_CLUSTER_NAME)"
	@rm -f $(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE)

.PHONY: terraform\:get-state
## Retrieve and untar terraform state from artifactory or emit error response
terraform\:get-state: %get-state:
	@echo "Getting archive file: $(TERRAFORM_STATE_ARTIFACTORY_URL)/$(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE)"
	@curl -H "X-JFrog-Art-Api: $(TERRAFORM_STATE_ARTIFACTORY_TOKEN)" -O "$(TERRAFORM_STATE_ARTIFACTORY_URL)/$(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE)"
	@file $(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE) | grep -q gzip && tar xzvf $(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE) || { head -n 10 $(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE); rm -f $(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE); exit 1; }
	@rm -f $(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE)

.PHONY: terraform\:delete-state
## Delete terraform state from artifactory
terraform\:delete-state: %delete-state:
	@echo "Deleting archive file: $(TERRAFORM_STATE_ARTIFACTORY_URL)/$(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE)"
	@curl -H "X-JFrog-Art-Api: $(TERRAFORM_STATE_ARTIFACTORY_TOKEN)" -X DELETE  "$(TERRAFORM_STATE_ARTIFACTORY_URL)/$(TERRAFORM_STATE_ARTIFACTORY_ARCHIVE)"
