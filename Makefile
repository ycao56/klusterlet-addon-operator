
SHELL := /bin/bash

.EXPORT_ALL_VARIABLES:

GIT_COMMIT      = $(shell git rev-parse --short HEAD)
GIT_REMOTE_URL  = $(shell git config --get remote.origin.url)
GITHUB_USER    := $(shell echo $(GITHUB_USER) | sed 's/@/%40/g')
GITHUB_TOKEN   ?=

ARCH       ?= $(shell uname -m)
BUILD_DATE  = $(shell date '+%m/%d@%H:%M:%S')
VCS_REF     = $(if $(shell git status --porcelain),$(GIT_COMMIT)-$(BUILD_DATE),$(GIT_COMMIT))

PROJECT_DIR            = $(shell 'pwd')
BUILD_DIR              = $(PROJECT_DIR)/build
COMPONENT_SCRIPTS_PATH = $(BUILD_DIR)

IMAGE_DESCRIPTION  = Endpoint_Component_Operator
DOCKER_FILE        = $(BUILD_DIR)/Dockerfile
DOCKER_REGISTRY   ?= quay.io
DOCKER_NAMESPACE  ?= open-cluster-management
DOCKER_IMAGE      ?= $(COMPONENT_NAME)
DOCKER_BUILD_TAG  ?= latest
DOCKER_TAG        ?= $(shell whoami)
DOCKER_BUILD_OPTS  = --build-arg VCS_REF=$(VCS_REF) \
	--build-arg VCS_URL=$(GIT_REMOTE_URL) \
	--build-arg IMAGE_NAME=$(DOCKER_IMAGE) \
	--build-arg IMAGE_DESCRIPTION=$(IMAGE_DESCRIPTION) \
	--build-arg IMAGE_VERSION=$(SEMVERSION)


BEFORE_SCRIPT := $(shell build/before-make.sh)

-include $(shell curl -s -H 'Authorization: token ${GITHUB_TOKEN}' -H 'Accept: application/vnd.github.v4.raw' -L https://api.github.com/repos/open-cluster-management/build-harness-extensions/contents/templates/Makefile.build-harness-bootstrap -o .build-harness-bootstrap; echo .build-harness-bootstrap)


.PHONY: deps
## Download all project dependencies
deps: init component/init

# TODO look into adding yamllint; doesn't like operator-sdk generated files
.PHONY: check
# ## Runs a set of required checks
check: ossccheck

.PHONY: ossccheck
ossccheck:
	ossc --check

.PHONY: ossc
ossc:
	ossc

.PHONY: build
## Builds operator binary inside of an image
build: component/build

.PHONY: operator\:build\:helm
operator\:build\:helm:
	./build/build-helm-operator-image.sh

.PHONY: operator\:build
operator\:build:
	$(info Building operator)
	$(info --IMAGE: $(DOCKER_IMAGE))
	$(info --TAG: $(DOCKER_BUILD_TAG))
	operator-sdk build $(DOCKER_IMAGE):$(DOCKER_BUILD_TAG) --image-build-args "$(DOCKER_BUILD_OPTS)"

.PHONY: operator\:run
operator\:run:
	operator-sdk up local --zap-devel --namespace=""

### HELPER UTILS #######################

.PHONY: utils\:crds\:install
utils\:crds\:install:
	for file in `ls deploy/crds/*_crd.yaml`; do kubectl apply -f $$file; done

.PHONY: utils\:crds\:uninstall
utils\:crds\:uninstall:
	for file in `ls deploy/crds/*_crd.yaml`; do kubectl delete -f $$file; done

.PHONY: utils\:charts\:versions
utils\:charts\:versions:
	ls versions

.PHONY: utils\:charts\:version
utils\:charts\:version:
	ln -sfn versions/$$version/watches.yaml watches.yaml
	ln -sfn versions/$$version/helm-charts helm-charts

.PHONY: utils\:link\:setup
utils\:link\:setup:
	sudo ln -sfn $$PWD/versions /opt