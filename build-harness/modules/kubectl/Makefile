CURL := $(shell which curl)
KUBECTL_VERSION ?= v1.10.0
KUBECTL_PLATFORM ?= $(BUILD_HARNESS_OS)
KUBECTL_ARCH ?= $(BUILD_HARNESS_ARCH)
KUBECTL_URL ?= https://storage.googleapis.com/kubernetes-release/release/$(KUBECTL_VERSION)/bin/$(KUBECTL_PLATFORM)/$(KUBECTL_ARCH)/kubectl
KUBECTL ?= $(BUILD_HARNESS_PATH)/vendor/kubectl

K8S_CLUSTER_NAME ?=
K8S_CLUSTER_MASTER_IP ?= 
# Console IP is used for http requests, which may be directly thru the master or thru a load balancer
K8S_CLUSTER_CONSOLE_IP ?= $(K8S_CLUSTER_MASTER_IP)
K8S_CLUSTER_MASTER_PORT ?= 8443
K8S_CLUSTER_SSH_USER ?= ubuntu
K8S_CLUSTER_SSH_PRIVATE_KEY = $(PWD)/id_rsa
KUBECTL_SSH_BASTION ?= $(K8S_CLUSTER_MASTER_IP)
KUBECTL_SSH_USER ?= $(K8S_CLUSTER_SSH_USER)
KUBECTL_SSH_PRIVATE_KEY ?= $(K8S_CLUSTER_SSH_PRIVATE_KEY)
KUBECTL_SSH_TUNNEL ?= $(KUBECTL_SSH_USER)@$(KUBECTL_SSH_BASTION)
KUBECTL_SSH_SOCK ?= /tmp/kubectl-$(KUBECTL_SSH_TUNNEL)
KUBECTL_SSH_OPTS := -A -o LogLevel=error -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $(KUBECTL_SSH_PRIVATE_KEY) -S $(KUBECTL_SSH_SOCK)
KUBECTL_SSH_CMD := ssh $(KUBECTL_SSH_OPTS)
KUBECTL_CA_CRT = if (sudo test -e /opt/ibm/cluster/cfc-certs/root-ca/ca.crt) ; then \
					sudo cat /opt/ibm/cluster/cfc-certs/root-ca/ca.crt ; \
				 else \
				 	sudo cat /opt/ibm/cluster/cfc-keys/ca.crt; \
				 fi
KUBECTL_KUBE_CRT = if (sudo test -e /opt/ibm/cluster/cfc-certs/kubernetes/kubecfg.crt) ; then \
						sudo cat /opt/ibm/cluster/cfc-certs/kubernetes/kubecfg.crt ; \
					else \
						sudo cat /opt/ibm/cluster/cfc-certs/kubecfg.crt; \
					fi
KUBECTL_KUBE_KEY = if (sudo test -e /opt/ibm/cluster/cfc-certs/kubernetes/kubecfg.key) ; then \
						sudo cat /opt/ibm/cluster/cfc-certs/kubernetes/kubecfg.key ; \
					else \
						sudo cat /opt/ibm/cluster/cfc-certs/kubecfg.key; \
					fi
# Add the SSH endpoint to the command; everything after the host is expected to be a remote command
KUBECTL_SSH_CMD += $(KUBECTL_SSH_TUNNEL)
KUBECTL_CMD ?= $(KUBECTL_SSH_CMD) "$(KUBECTL)" --logtostderr=true --insecure-skip-tls-verify=true

# Specify DEBUG=/dev/stderr to get useful output to stderr 
# Specify DEBUG=/dev/null to discard output
DEBUG ?= /dev/stderr


KUBECTL_RESOURCE_PATH ?= $(PWD)/.kubectl
KUBECTL_CLUSTER_CONFIG_PATH ?= $(KUBECTL_RESOURCE_PATH)/$(K8S_CLUSTER_NAME)/etc/
CLUSTER_CONSOLE ?= https://$(K8S_CLUSTER_CONSOLE_IP):$(K8S_CLUSTER_MASTER_PORT)


.PHONY: kubectl\:check\:def
#Check what variables have been defined
kubectl\:check\:def: %check\:def:
ifndef K8S_CLUSTER_NAME
	$(info K8S_CLUSTER_NAME not defined)
	exit -1
endif
ifndef K8S_CLUSTER_MASTER_IP
	$(info K8S_CLUSTER_MASTER_IP not defined)
	exit -1
endif
ifeq ($(CLUSTER_CONSOLE),https://:$(K8S_CLUSTER_MASTER_PORT))
	$(info K8S_CLUSTER_MASTER_IP: "$(K8S_CLUSTER_MASTER_IP)")
	$(info K8S_CLUSTER_CONSOLE_IP: "$(K8S_CLUSTER_CONSOLE_IP)")
	$(info K8S_CLUSTER_CONSOLE: "$(CLUSTER_CONSOLE)")
	$(info Define one of the following: K8S_CLUSTER_MASTER_IP, K8S_CLUSTER_CONSOLE_IP, CLUSTER_CONSOLE)
	exit -1
endif

.PHONY: kubectl\:install
## Install kubectl
kubectl\:install: %install:
	@( echo "Installing kubectl $(KUBECTL_VERSION) for $(KUBECTL_PLATFORM) $(KUBECTL_ARCH) from $(KUBECTL_URL)" && \
		curl '-#' -fL -o $(TMP)/kubectl -LO $(KUBECTL_URL) && \
		chmod +x $(TMP)/kubectl && \
		mv $(TMP)/kubectl $(KUBECTL) \
		)
	@$(KUBECTL) version --client

.PHONY: kubectl\:install\:cluster
## Install kubectl from the cluster at K8S_CLUSTER_CONSOLE_IP
kubectl\:install\:cluster: %install\:cluster:
	@( echo "Installing kubectl for $(KUBECTL_PLATFORM) $(KUBECTL_ARCH) from $(CLUSTER_CONSOLE)/api/cli/kubectl-$(KUBECTL_PLATFORM)-$(KUBECTL_ARCH)" && \
		curl '-#' -fL -ko $(TMP)/kubectl -LO $(CLUSTER_CONSOLE)/api/cli/kubectl-$(KUBECTL_PLATFORM)-$(KUBECTL_ARCH) && \
		chmod +x $(TMP)/kubectl && \
		mv $(TMP)/kubectl $(KUBECTL) \
		)
	@$(KUBECTL) version --client

.PHONY: kubectl\:tunnel-up
## Bring up SSH tunnel for kubernetes commands, must be called before executing any targets
kubectl\:tunnel-up: %tunnel-up:
	@ssh $(KUBECTL_SSH_OPTS) -M -f -N $(KUBECTL_SSH_TUNNEL)

.PHONY: kubectl\:tunnel-down
## Tear down kubernetes SSH tunnel, must be called after executing other targets
kubectl\:tunnel-down: %tunnel-down:
	@[ -e $(KUBECTL_SSH_SOCK) ] && ssh -S $(KUBECTL_SSH_SOCK) -O exit $(KUBECTL_SSH_TUNNEL)

.PHONY: kubectl\:info
## Display info about the kubernetes setup
kubectl\:info: %info:
	@echo -e "SSH Tunnel: $(call yellow,$(KUBECTL_SSH_TUNNEL))"
	@echo -e "SSH User: $(call yellow,$(KUBECTL_SSH_USER))"
	@echo -e "SSH Key: $(call yellow,$(KUBECTL_SSH_PRIVATE_KEY))"
	@echo -e "Cluster Name: $(call yellow,$(K8S_CLUSTER_NAME))"
	@echo -e "Cluster Master IP: $(call yellow,$(K8S_CLUSTER_MASTER_IP))"

kubectl\:make_configpath:
	@mkdir -p $(KUBECTL_CLUSTER_CONFIG_PATH)

.PHONY: kubectl\:config
## Create kubectl config for $K8S_CLUSTER_NAME
kubectl\:config: %config: %check:def %make_configpath
	@$(SELF) -s kubectl:install:cluster
	$(call assert-set,KUBECTL)
	@$(SELF) -s kubectl:tunnel-up
	@$(KUBECTL_SSH_CMD) '/bin/bash -c '"'"'$(KUBECTL_CA_CRT)'"'"'' > $(KUBECTL_CLUSTER_CONFIG_PATH)/ca.crt
	@$(KUBECTL_SSH_CMD) '/bin/bash -c '"'"'$(KUBECTL_KUBE_KEY)'"'"'' > $(KUBECTL_CLUSTER_CONFIG_PATH)/kubecfg.key
	@$(KUBECTL_SSH_CMD) '/bin/bash -c '"'"'$(KUBECTL_KUBE_CRT)'"'"'' > $(KUBECTL_CLUSTER_CONFIG_PATH)/kubecfg.crt	
	@$(KUBECTL_SSH_CMD) '/bin/bash -c '"'"'sudo cat /opt/ibm/cluster/config.yaml'"'"'' > $(KUBECTL_CLUSTER_CONFIG_PATH)/config.yaml
	@$(KUBECTL) config set-cluster $(K8S_CLUSTER_NAME) --server=https://$(K8S_CLUSTER_CONSOLE_IP):8001 --insecure-skip-tls-verify=true
	@$(KUBECTL) config set-context $(K8S_CLUSTER_NAME) --cluster=$(K8S_CLUSTER_NAME)
	@$(KUBECTL) config set-credentials $(K8S_CLUSTER_NAME) --client-certificate=$(KUBECTL_CLUSTER_CONFIG_PATH)/kubecfg.crt --client-key=$(KUBECTL_CLUSTER_CONFIG_PATH)/kubecfg.key
	@$(KUBECTL) config set-context $(K8S_CLUSTER_NAME) --user=$(K8S_CLUSTER_NAME)
	@$(KUBECTL) config use-context $(K8S_CLUSTER_NAME)
	@$(SELF) -s kubectl:tunnel-down

.PHONY: kubectl\:cmd
## Execute $KUBECTL_COMMAND against $K8S_CLUSTER_MASTER_IP
kubectl\:cmd: %cmd:
	$(call assert-set,KUBECTL)
	@$(KUBECTL) $(KUBECTL_COMMAND)
