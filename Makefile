
SHELL := /bin/bash

export GITHUB_USER    := $(shell echo $(GITHUB_USER) | sed 's/@/%40/g')
export GITHUB_TOKEN   ?=

export ARCH       ?= $(shell uname -m)
export BUILD_DATE  = $(shell date '+%m/%d@%H:%M:%S')

export PROJECT_DIR            = $(shell 'pwd')
export BUILD_DIR              = $(PROJECT_DIR)/build
export COMPONENT_SCRIPTS_PATH = $(BUILD_DIR)

export IMAGE_DESCRIPTION  = Klusterlet_Component_Operator
export DOCKER_FILE        = $(BUILD_DIR)/Dockerfile
export DOCKER_REGISTRY   ?= quay.io
export DOCKER_NAMESPACE  ?= open-cluster-management
export DOCKER_IMAGE      ?= $(COMPONENT_NAME)
export DOCKER_BUILD_TAG  ?= latest
export DOCKER_TAG        ?= $(shell whoami)
export DOCKER_BUILD_OPTS  = --build-arg VCS_REF=$(VCS_REF) \
	--build-arg VCS_URL=$(GIT_REMOTE_URL) \
	--build-arg IMAGE_NAME=$(DOCKER_IMAGE) \
	--build-arg IMAGE_DESCRIPTION=$(IMAGE_DESCRIPTION) \
	--build-arg IMAGE_VERSION=$(SEMVERSION) \
	--build-arg REMOTE_SOURCE=. \
	--build-arg REMOTE_SOURCE_DIR=/remote-source 

COMPONENT_NAME=$(shell cat $(PWD)/COMPONENT_NAME 2> /dev/null)
COMPONENT_VERSION=$(shell cat $(PWD)/COMPONENT_VERSION 2> /dev/null)

# COMPONENT_TAG_EXTENSION=-dom
BEFORE_SCRIPT := $(shell build/before-make.sh)

USE_VENDORIZED_BUILD_HARNESS ?=

ifndef USE_VENDORIZED_BUILD_HARNESS
-include $(shell curl -s -H 'Authorization: token ${GITHUB_TOKEN}' -H 'Accept: application/vnd.github.v4.raw' -L https://api.github.com/repos/open-cluster-management/build-harness-extensions/contents/templates/Makefile.build-harness-bootstrap -o .build-harness-bootstrap; echo .build-harness-bootstrap)
else
-include vbh/.build-harness-vendorized
endif

# Only use git commands if it exists
ifdef GIT
GIT_COMMIT      = $(shell git rev-parse --short HEAD)
GIT_REMOTE_URL  = $(shell git config --get remote.origin.url)
VCS_REF     = $(if $(shell git status --porcelain),$(GIT_COMMIT)-$(BUILD_DATE),$(GIT_COMMIT))
endif

.PHONY: deps
## Download all project dependencies
deps: init component/init

# TODO look into adding yamllint; doesn't like operator-sdk generated files
.PHONY: check
# ## Runs a set of required checks
check: ossccheck copyright-check

.PHONY: ossccheck
ossccheck:
	ossc --check

.PHONY: ossc
ossc:
	ossc

.PHONY: build
## Builds operator binary inside of an image
build: component/build

.PHONY: copyright-check
copyright-check:
	./build/copyright-check.sh $(TRAVIS_BRANCH)

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
	# operator-sdk run --local --operator-flags="--zap-devel=true" --namespace=""
	operator-sdk-v0.9.0 up local --operator-flags="--zap-devel=true" --namespace=""

### HELPER UTILS #######################

.PHONY: utils/crds/install
utils/crds/install:
	for file in `ls deploy/crds/agent.open-cluster-management.io_*_crd.yaml`; do kubectl apply -f $$file; done

.PHONY: utils/crds/uninstall
utils/crds/uninstall:
	for file in `ls deploy/crds/agent.open-cluster-management.io_*_crd.yaml`; do kubectl delete -f $$file; done

.PHONY: utils\:charts\:versions
utils\:charts\:versions:
	ls versions

.PHONY: utils/charts/version
utils/charts/version:
	ln -sfn versions/$$version/watches.yaml watches.yaml
	ln -sfn versions/$$version/helm-charts helm-charts

.PHONY: utils/link/setup
utils/link/setup:
	sudo ln -sfn $$PWD/versions /opt/helm

.PHONY: delete-cluster
delete-cluster:
	kubectl config unset current-context; \
	kubectl config delete-context kind-test-cluster; \
	kind delete cluster --name=test-cluster

.PHONY: functional-test-full
functional-test-full: build component/test/functional

.PHONY: functional-test-full-no-build
functional-test-full-no-build: build component/test/functional
