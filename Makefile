IMAGE_NAME ?= klusterlet-component-operator
SCRATCH_REPO ?= hyc-cloud-private-scratch-docker-local.artifactory.swg-devops.com/ibmcom
SCRATCH_TAG ?= ${shell whoami}

.PHONY: install-crd
install-crd:
	for file in `ls deploy/crds/*crd.yaml`; do kubectl apply -f $$file; done

.PHONY: run
run:
	operator-sdk up local --zap-devel --namespace=""

.PHONY: operator
operator:
	operator-sdk build ${SCRATCH_REPO}/${IMAGE_NAME}:${SCRATCH_TAG}


