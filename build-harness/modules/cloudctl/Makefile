CURL := $(shell which curl)
CLOUDCTL_PLATFORM ?= $(BUILD_HARNESS_OS)
CLOUDCTL_ARCH ?= $(BUILD_HARNESS_ARCH)
CLOUDCTL ?= $(BUILD_HARNESS_PATH)/vendor/cloudctl
CLOUDCTL_TRACE := true

K8S_CLUSTER_NAME ?=
K8S_CLUSTER_MASTER_IP ?= 
K8S_CLUSTER_MASTER_PORT ?= 8443
K8S_CLUSTER_USER ?= admin
K8S_CLUSTER_PASSWORD ?=
K8S_CLUSTER_ID ?= id-mycluster-account
K8S_CLUSTER_NAMESPACE ?= kube-system
OPENSHIFT_ICP_CONSOLE?= https://$(K8S_CLUSTER_MASTER_IP):$(K8S_CLUSTER_MASTER_PORT)
# Specify DEBUG=/dev/stderr to get useful output to stderr 
# Specify DEBUG=/dev/null to discard output
DEBUG ?= /dev/stderr

CLOUDCTL_RESOURCE_PATH ?= $(PWD)/.cloudctl
CLOUDCTL_CLUSTER_CONFIG_PATH ?= $(CLOUDCTL_RESOURCE_PATH)/$(K8S_CLUSTER_NAME)/etc/

.PHONY: cloudctl\:check\:def
#Check what variables have been defined
cloudctl\:check\:def: %check\:def:
ifndef K8S_CLUSTER_NAME
	$(info K8S_CLUSTER_NAME not defined)
	exit -1
endif
ifndef K8S_CLUSTER_MASTER_IP
	$(info K8S_CLUSTER_MASTER_IP not defined)
	exit -1
endif
ifndef K8S_CLUSTER_PASSWORD
	$(info K8S_CLUSTER_MASTER_PORT not defined)
	exit -1
endif

.PHONY: cloudctl\:install\:cluster
## Cloudctl install from a specific cluster
cloudctl\:install\:cluster: %install\:cluster: %check:def 
	@( echo "Installing cloudctl for $(CLOUDCTL_PLATFORM) $(CLOUDCTL_ARCH) from $(OPENSHIFT_ICP_CONSOLE)/api/cli/cloudctl-$(CLOUDCTL_PLATFORM)-$(CLOUDCTL_ARCH)" && \
		curl '-#' -fL -ko $(TMP)/cloudctl -LO $(OPENSHIFT_ICP_CONSOLE)/api/cli/cloudctl-$(CLOUDCTL_PLATFORM)-$(CLOUDCTL_ARCH) && \
		chmod +x $(TMP)/cloudctl && \
		mv $(TMP)/cloudctl $(CLOUDCTL) \
		)
	@$(CLOUDCTL) version
	@$(SELF) helm:install:cluster CLUSTER_CONSOLE=$(OPENSHIFT_ICP_CONSOLE)
	@$(SELF) kubectl:install:cluster CLUSTER_CONSOLE=$(OPENSHIFT_ICP_CONSOLE)

cloudctl\:make_configpath:
	@mkdir -p $(HELM_CLUSTER_CONFIG_PATH)

.PHONY: cloudctl\:config
## Create cloudctl config for $K8S_CLUSTER_NAME
cloudctl\:config: %config: %check:def %make_configpath
	@$(SELF) -s cloudctl:install:cluster
	$(call assert-set,CLOUDCTL)
	@$(SELF) -s helm:make_configpath
	@$(SELF) -s kubectl:make_configpath
	@$(CLOUDCTL) login -a $(OPENSHIFT_ICP_CONSOLE) --skip-ssl-validation -u $(K8S_CLUSTER_USER) -p $(K8S_CLUSTER_PASSWORD) -n $(K8S_CLUSTER_NAMESPACE)


.PHONY: cloudctl\:cmd
## Execute $CLOUDCTL_COMMAND against $K8S_CLUSTER_MASTER_IP
cloudctl\:cmd: %cmd:
	$(call assert-set,CLOUDCTL)
	@$(CLOUDCTL) $(CLOUDCTL_COMMAND) --skip-ssl-validation
