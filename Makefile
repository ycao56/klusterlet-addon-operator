BINDIR ?= output

DOCKER_USER      ?=$(ARTIFACTORY_USER)
DOCKER_PASS      ?=$(ARTIFACTORY_PASS)
DOCKER_REGISTRY  ?= hyc-cloud-private-scratch-docker-local.artifactory.swg-devops.com
DOCKER_NAMESPACE ?= ibmcom
DOCKER_TAG       ?= $(RELEASE_TAG)

WORKING_CHANGES   = $(shell git status --porcelain)
BUILD_DATE        = $(shell date '+%m/%d@%H:%M:%S')
GIT_REMOTE_URL    = $(shell git config --get remote.origin.url)
GIT_COMMIT        = $(shell git rev-parse --short HEAD)
VCS_REF           = $(if $(WORKING_CHANGES),$(GIT_COMMIT)-$(BUILD_DATE),$(GIT_COMMIT))

ARCH ?= $(shell uname -m)
ifeq ($(ARCH), x86_64)
	IMAGE_NAME_ARCH = $(IMAGE_NAME)-amd64
else
	IMAGE_NAME_ARCH = $(IMAGE_NAME)-$(ARCH)
	DOCKER_FILE     = Dockerfile.$(ARCH)
endif

# Variables for Red Hat required labels
IMAGE_NAME            = klusterlet-component-operator
IMAGE_DESCRIPTION     = IBM_Multicloud_Component_Operator
IMAGE_MAINTAINER      = liuhao@us.ibm.com
IMAGE_VENDOR          = IBM
IMAGE_SUMMARY         = $(IMAGE_DESCRIPTION)
IMAGE_OPENSHIFT_TAGS  = multicloud-manager
IMAGE_VERSION        ?= $(RELEASE_TAG)
IMAGE_RELEASE        ?= $(VCS_REF)

DOCKER_BUILD_OPTS = --build-arg VCS_REF=$(VCS_REF) \
	--build-arg VCS_URL=$(GIT_REMOTE_URL) \
	--build-arg IMAGE_NAME=$(IMAGE_NAME) \
	--build-arg IMAGE_MAINTAINER=$(IMAGE_MAINTAINER) \
	--build-arg IMAGE_VENDOR=$(IMAGE_VENDOR) \
	--build-arg IMAGE_VERSION=$(IMAGE_VERSION) \
	--build-arg IMAGE_RELEASE=$(IMAGE_RELEASE) \
	--build-arg IMAGE_SUMMARY=$(IMAGE_SUMMARY) \
	--build-arg IMAGE_OPENSHIFT_TAGS=$(IMAGE_OPENSHIFT_TAGS) \
	--build-arg IMAGE_NAME_ARCH=$(IMAGE_NAME_ARCH) \
	--build-arg IMAGE_DESCRIPTION=$(IMAGE_DESCRIPTION)

GITHUB_USER := $(shell echo $(GITHUB_USER) | sed 's/@/%40/g')

BEFORE_SCRIPT := $(shell build/before-make.sh)

include .build-harness


.PHONY: init
init:: operator\:tools
ifndef GITHUB_USER
	$(info GITHUB_USER not defined)
	exit -1
endif
	$(info Using GITHUB_USER=$(GITHUB_USER))
ifndef GITHUB_TOKEN
	$(info GITHUB_TOKEN not defined)
	exit -1
endif

.PHONY: check
# check: go\:copyright\:check lint\:yaml
check:
	$(info TODO Skipping checks initially)

.PHONY: test
test:
	$(info TODO Skipping tests initially)

.PHONY: install-crd
install-crd:
	kubectl apply -f deploy/crds/klusterlet_v1alpha1_klusterletservice_crd.yaml

# ### OPERATOR SDK #######################
.PHONY: operator\:tools
operator\:tools:
	./build/install-operator-sdk.sh

.PHONY: operator\:build
operator\:build:
	$(info Building operator)
	$(info --REPO: $(DOCKER_REGISTRY)/$(DOCKER_NAMESPACE))
	$(info --IMAGE: $(DOCKER_IMAGE))
	$(info --TAG: $(DOCKER_TAG))
	operator-sdk build $(DOCKER_REGISTRY)/$(DOCKER_NAMESPACE)/$(DOCKER_IMAGE):$(DOCKER_TAG) --image-build-args "$(DOCKER_BUILD_OPTS)"

.PHONY: operator\:run
operator\:run:
	operator-sdk up local --zap-devel --namespace=""
