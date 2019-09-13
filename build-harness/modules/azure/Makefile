#######################################
## Interface to azure command line client
## Supports installing azure client from pip, but most reliable
## and suggested approach from Microsoft is via package manager,
## adding following lines to .travis.yaml (or similar)
##
## before_install:
##   - AZ_REPO=$(lsb_release -cs) && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
##   - curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
##   - sudo apt-get install apt-transport-https
##   - sudo apt-get update && sudo apt-get install azure-cli
##
#######################################
# Use existing az cli if installed
AZ ?= $(shell which az)

# Try take Azure Auth information from Terraform if not set specifically
AZURECLI_USERNAME ?= $(ARM_CLIENT_ID)
AZURECLI_PASSWORD ?= $(ARM_CLIENT_SECRET)
AZURECLI_TENANT ?= $(ARM_TENANT_ID)

# Default Azure ClI settings
AZURECLI_NOWAIT ?= "--no-wait"


# If az binary was not detected we will install in a python venv
ifeq ($(AZ),)
	# If installing in a new venv
	PYTHON3 ?= $(shell which python3)
	AZURECLI_VER ?= 2.0.62
	AZURECLI_DIR ?= $(BUILD_HARNESS_PATH)/vendor/azure-cli
	AZURECLI_VENV_DIR ?= $(AZURECLI_DIR)/azurecli-pyvenv
	AZURECLI_VENV_ACTIVATE = $(AZURECLI_VENV_DIR)/bin/activate

	AZURECLI_CREATE_VENV = true
	AZURECLI_VENV_SOURCE = source $(AZURECLI_VENV_ACTIVATE)
	AZ = $(AZURECLI_VENV_DIR)/bin/az
	AZ_EXEC = $(AZURECLI_VENV_SOURCE) ; $(AZ)
else
	# When az is already installed we don't need to install venv
	AZURECLI_VENV_SOURCE = echo -n
	AZURECLI_CREATE_VENV = false
	AZ_EXEC = $(AZ)
endif

ifdef VIRTUAL_ENV
	# If VIRTUAL_ENV is set we're already in a
	# virtual env so do not need to install new
	AZURECLI_VENV_ACTIVATE =
	AZURECLI_VENV_SOURCE = echo -n
	AZURECLI_CREATE_VENV = false
	AZ_EXEC = $(AZ)
endif


# If azure client is not already existing
# on the system we will install it in a venv
.PHONY: azure\:venv-init
## Initialize pip virtual environment for azure cli
azure\:venv-init: %azure\:venv-init:
ifeq ($(AZURECLI_CREATE_VENV),true)
	$(PYTHON3) -m venv $(AZURECLI_VENV_DIR)
	$(AZURECLI_VENV_SOURCE); \
	pip3 install --upgrade pip > /dev/null; \
	python3 -V; \
	pip3 -V
endif

.PHONY: azure\:install
## Install Azure Command Line Client
azure\:install: %azure\:install: %azure:venv-init
	@[ -x $(AZ) ] || ( \
		$(AZURECLI_VENV_SOURCE); \
		echo "Installing az version $(AZURECLI_VER) using pip into venv $(AZURECLI_VENV_DIR)" ; \
		pip3 install azure-cli==$(AZURECLI_VER) \
	  )
	$(AZ_EXEC) --version

.PHONY: azure\:init
## Initialize azure client and setup authentication
azure\:init: %azure\:init: %azure:venv-init %azure:install
	@$(AZ_EXEC) login --service-principal --username $(AZURECLI_USERNAME) --password $(AZURECLI_PASSWORD) --tenant $(AZURECLI_TENANT)

.PHONY: azure\:cleanrg
## Delete an Azure resource group and all it's content
azure\:cleanrg: %azure\:cleanrg: %azure:venv-init %azure:install %azure:init
ifndef AZURE_RESOURCE_GROUP
	$(info AZURE_RESOURCE_GROUP not set)
	exit 1
endif
	echo "Deleting resource group $(AZURE_RESOURCE_GROUP)"
	$(AZ_EXEC) group delete --name $(AZURE_RESOURCE_GROUP) --yes $(AZURECLI_NOWAIT)

.PHONY: azure\:clean
## Remove azure config files holding auth information
azure\:clean:
	rm -rf ~/.azure
