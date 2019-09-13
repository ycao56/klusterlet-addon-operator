CURL := $(shell which curl)
HELM_VERSION ?= v2.12.1
HELM_PLATFORM ?= $(BUILD_HARNESS_OS)
HELM_ARCH ?= $(BUILD_HARNESS_ARCH)
HELM_URL ?= https://kubernetes-helm.storage.googleapis.com/helm-$(HELM_VERSION)-$(HELM_PLATFORM)-$(HELM_ARCH).tar.gz
HELM ?= $(BUILD_HARNESS_PATH)/vendor/helm
HELM_HOME ?= $(HOME)/.helm

K8S_CLUSTER_NAME ?=
K8S_CLUSTER_MASTER_IP ?=
# Console IP is used for http requests, which may be directly thru the master or thru a load balancer
K8S_CLUSTER_CONSOLE_IP ?= $(K8S_CLUSTER_MASTER_IP)
K8S_CLUSTER_MASTER_PORT ?= 8443
K8S_CLUSTER_SSH_USER ?= ubuntu
K8S_CLUSTER_SSH_PRIVATE_KEY = $(PWD)/id_rsa

HELM_SSH_BASTION ?= $(K8S_CLUSTER_MASTER_IP)
HELM_SSH_USER ?= $(K8S_CLUSTER_SSH_USER)
HELM_SSH_PRIVATE_KEY ?= $(K8S_CLUSTER_SSH_PRIVATE_KEY)
HELM_SSH_TUNNEL ?= $(HELM_SSH_USER)@$(HELM_SSH_BASTION)
HELM_SSH_SOCK ?= /tmp/helm-$(HELM_SSH_TUNNEL)
HELM_SSH_OPTS := -A -o LogLevel=error -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $(HELM_SSH_PRIVATE_KEY) -S $(HELM_SSH_SOCK)
HELM_SSH_CMD := ssh $(HELM_SSH_OPTS)

HELM_CA_CRT = if (sudo test -e /opt/ibm/cluster/cfc-certs/root-ca/ca.crt) ; then \
					sudo cat /opt/ibm/cluster/cfc-certs/root-ca/ca.crt ; \
				 else \
				 	sudo cat /opt/ibm/cluster/cfc-keys/ca.crt; \
				 fi
HELM_ADMIN_CRT = sudo cat /opt/ibm/cluster/cfc-certs/helm/admin.crt
HELM_ADMIN_KEY = sudo cat /opt/ibm/cluster/cfc-certs/helm/admin.key

# Add the SSH endpoint to the command; everything after the host is expected to be a remote command
HELM_SSH_CMD += $(HELM_SSH_TUNNEL)
# HELM_CMD ?= $(HELM_SSH_CMD) "$(HELM)" --logtostderr=true --insecure-skip-tls-verify=true

HELM_RESOURCE_PATH ?= $(PWD)/.helm
HELM_CLUSTER_CONFIG_PATH ?= $(HELM_RESOURCE_PATH)/$(K8S_CLUSTER_NAME)
HELM_TLS_STRING ?= "--tls --tls-ca-cert $(HELM_CLUSTER_CONFIG_PATH)/ca.crt --tls-cert $(HELM_CLUSTER_CONFIG_PATH)/admin.crt --tls-key $(HELM_CLUSTER_CONFIG_PATH)/admin.key"

HELM_FROM_REPO ?=
HELM_FROM_CHART ?=
HELM_FROM_VERSION ?=
HELM_TO_REPO ?=
HELM_TO_CHART ?=
HELM_TO_VERSION ?=

HELM_ARTIFACTORY_TOKEN ?= $(ARTIFACTORY_TOKEN)
HELM_ARTIFACTORY_URL ?= $(ARTIFACTORY_URL)
CLUSTER_CONSOLE ?= https://$(K8S_CLUSTER_CONSOLE_IP):$(K8S_CLUSTER_MASTER_PORT)

.PHONY: helm\:check\:def
#Check what variables have been defined
helm\:check\:def: %check\:def:
ifndef K8S_CLUSTER_NAME
	$(info K8S_CLUSTER_NAME not defined)
	exit -1
endif
ifndef K8S_CLUSTER_MASTER_IP
	$(info K8S_CLUSTER_MASTER_IP not defined)
	exit -1
endif
ifeq ($(CLUSTER_CONSOLE),https://:$(K8S_CLUSTER_MASTER_PORT))
	$(info Define one of the following: K8S_CLUSTER_MASTER_IP, K8S_CLUSTER_CONSOLE_IP, CLUSTER_CONSOLE)
	exit -1
endif

.PHONY: helm\:install
## Install helm
helm\:install: %install:
	@[ -x $(HELM) ] || ( \
		echo "Installing Helm $(HELM_VERSION) ($(HELM_PLATFORM)-$(HELM_ARCH)) from $(HELM_URL)" && \
		curl '-#' -fL -o $(TMP)/helm.tar.gz $(HELM_URL) && \
		tar xzf $(TMP)/helm.tar.gz -C $(TMP)/ && \
		mv $(TMP)/$(HELM_PLATFORM)-$(HELM_ARCH)/helm $(HELM) && \
		rm -f $(TMP)/helm.tar.gz && \
		rm -rf $(TMP)/$(HELM_PLATFORM)-$(HELM_ARCH)/ \
		)
	$(HELM) version --client

.PHONY: helm\:install\:cluster
## Install helm from the cluster at K8S_CLUSTER_CONSOLE_IP
helm\:install\:cluster: %install\:cluster:
	@(	echo "Installing helm for $(HELM_PLATFORM) $(HELM_ARCH) from $(CLUSTER_CONSOLE)/api/cli/helm-$(HELM_PLATFORM)-$(HELM_ARCH).tar.gz" && \
		curl '-#' -fL -ko $(TMP)/helm.tar.gz -LO $(CLUSTER_CONSOLE)/api/cli/helm-$(HELM_PLATFORM)-$(HELM_ARCH).tar.gz && \
		tar xzf $(TMP)/helm.tar.gz -C $(TMP)/ && \
		mv $(TMP)/$(HELM_PLATFORM)-$(HELM_ARCH)/helm $(HELM) && \
		rm -f $(TMP)/helm.tar.gz && \
		rm -rf $(TMP)/$(HELM_PLATFORM)-$(HELM_ARCH)/ \
		)
	$(HELM) version --client

.PHONY: helm\:tunnel-up
## Bring up SSH tunnel for helm commands, must be called before executing any targets
helm\:tunnel-up: %tunnel-up:
	@ssh $(HELM_SSH_OPTS) -M -f -N $(HELM_SSH_TUNNEL)

.PHONY: helm\:tunnel-down
## Tear down helm SSH tunnel, must be called after executing other targets
helm\:tunnel-down: %tunnel-down:
	@[ -e $(HELM_SSH_SOCK) ] && ssh -S $(HELM_SSH_SOCK) -O exit $(HELM_SSH_TUNNEL)

helm\:make_configpath:
	@mkdir -p $(HELM_CLUSTER_CONFIG_PATH)

.PHONY: helm\:config
## Create helm config for $K8S_CLUSTER_NAME
helm\:config: %config: %check:def %make_configpath
	@$(SELF) -s helm:install:cluster
	$(call assert-set,HELM)
	@$(SELF) -s helm:tunnel-up
	@$(HELM_SSH_CMD) '/bin/bash -c '"'"'$(HELM_CA_CRT)'"'"'' > $(HELM_CLUSTER_CONFIG_PATH)/ca.crt
	@$(HELM_SSH_CMD) '/bin/bash -c '"'"'$(HELM_ADMIN_CRT)'"'"'' > $(HELM_CLUSTER_CONFIG_PATH)/admin.crt
	@$(HELM_SSH_CMD) '/bin/bash -c '"'"'$(HELM_ADMIN_KEY)'"'"'' > $(HELM_CLUSTER_CONFIG_PATH)/admin.key
	@$(SELF) -s helm:tunnel-down

.PHONY: helm\:init
## Build index to serve helm charts
helm\:init: %init: %install
	$(call assert-set,HELM)
	@$(HELM) init --client-only
	@chmod -R 777 "$(HELM_HOME)"

.PHONY: helm\:tls-cmd
## Execute $HELM_COMMAND with --tls options
helm\:tls-cmd: %tls-cmd:
	$(call assert-set,HELM)
	@$(HELM) $(HELM_COMMAND) "$(HELM_TLS_STRING)"

.PHONY: helm\:cmd
## Execute $HELM_COMMAND
helm\:cmd: %cmd:
	$(call assert-set,HELM)
	@$(HELM) $(HELM_COMMAND)

.PHONY: helm\:copy
## Copy helm chart from one location to another
helm\:copy: %copy:
	@$(call assert_set,HELM_FROM_REPO)
	@$(call assert_set,HELM_FROM_CHART)
	@$(call assert_set,HELM_FROM_VERSION)
	@$(call assert_set,HELM_TO_REPO)
	@$(call assert_set,HELM_TO_CHART)
	@$(call assert_set,HELM_TO_VERSION)
	@$(call assert_set,HELM_ARTIFACTORY_TOKEN)
	@$(call assert_set,HELM_ARTIFACTORY_URL)
	$(BUILD_HARNESS_PATH)/modules/helm/bin/copy.sh $(HELM_FROM_REPO) $(HELM_FROM_CHART) $(HELM_FROM_VERSION) $(HEML_TO_REPO) $(HELM_TO_CHART) $(HELM_TO_VERSION) $(HELM_ARTIFACTORY_TOKEN) $(HELM_ARTIFACTORY_URL)
