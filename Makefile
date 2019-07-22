IMAGE_NAME ?= klusterlet-component-operator
SCRATCH_REPO ?= hyc-cloud-private-scratch-docker-local.artifactory.swg-devops.com/ibmcom
SCRATCH_TAG ?= ${shell whoami}

.PHONY: install-crd
install-crd:
	kubectl apply -f deploy/crds/klusterlet_v1alpha1_klusterletservice_crd.yaml

.PHONY: operator\:run
operator\:run:
	operator-sdk up local --zap-devel --namespace=""

.PHONY: operator\:build
operator\:build:
	operator-sdk build ${SCRATCH_REPO}/${IMAGE_NAME}:${SCRATCH_TAG}


