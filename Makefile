# Copyright Contributors to the Open Cluster Management project


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
export DOCKER_REGISTRY   ?= quay.io/open-cluster-management
export DOCKER_IMAGE      ?= klusterlet-addon-operator
export DOCKER_TAG        ?= latest
export DOCKER_BUILDER    ?= docker

# COMPONENT_TAG_EXTENSION=-dom
BEFORE_SCRIPT := $(shell build/before-make.sh)

.PHONY: deps
## Download all project dependencies
deps: init 

# TODO look into adding yamllint; doesn't like operator-sdk generated files
.PHONY: check
# ## Runs a set of required checks
check: copyright-check

.PHONY: build-image
## Builds controller binary inside of an image
build-image: 
	@$(DOCKER_BUILDER) build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE} -f $(DOCKER_FILE) . 
	@$(DOCKER_BUILDER) tag ${DOCKER_REGISTRY}/${DOCKER_IMAGE} ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:$(DOCKER_TAG)

.PHONY: copyright-check
copyright-check:
	./build/copyright-check.sh $(TRAVIS_BRANCH)

.PHONY: operator\:build\:helm
operator\:build\:helm:
	./build/build-helm-operator-image.sh

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

.PHONY: utils/link/setup
utils/link/setup:
	sudo ln -sfn $$PWD/helm-charts /opt/helm

.PHONY: delete-cluster
delete-cluster:
	kubectl config unset current-context; \
	kubectl config delete-context kind-test-cluster; \
	kind delete cluster --name=test-cluster

.PHONY: functional-test-full
functional-test-full: build-image
	build/run-functional-tests.sh ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:$(DOCKER_TAG)

.PHONY: functional-test-full-no-build
functional-test-full-no-build: build component/test/functional
