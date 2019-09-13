SSH := $(shell which ssh)
SSH_KEYGEN := $(shell which ssh-keygen)
SSH_KEY_FILE ?= $(HOME)/.ssh/build-harness/id_rsa
SSH_KEY_FILE_LINK = $(shell pwd)/id_rsa
ECHO_SSH_KEYS ?= 


SSH_GITHUB_USER ?= $(GITHUB_USER)
SSH_GITHUB_TOKEN ?= $(GITHUB_TOKEN)
SSH_GIT_TRAVIS_KEY_PROJECT ?= "https://$(SSH_GITHUB_USER):$(SSH_GITHUB_TOKEN)@github.ibm.com/ICP-DevOps/travis_os_keys.git"
SSH_GIT_TRAVIS_KEY_BRANCH ?= master
SSH_KEY_DIR ?= .os_travis_ssh_key

ifdef HAS_JOSH_K_SEAL_OF_APPROVAL
	SSH_KEY_FILE = $(SSH_KEY_DIR)/id_rsa
endif

SSH_DO_NOT_USE_HARNESS_KEYPAIR ?= 

.PHONY: ssh\:deps
ssh\:deps: %deps:
ifdef SSH_DO_NOT_USE_HARNESS_KEYPAIR
	return 0
endif
ifdef HAS_JOSH_K_SEAL_OF_APPROVAL
	@# We are in Travis, so pull the repo
	@rm -rf $(SSH_KEY_DIR)
	@$(GIT) clone -b $(SSH_GIT_TRAVIS_KEY_BRANCH) $(SSH_GIT_TRAVIS_KEY_PROJECT) $(SSH_KEY_DIR)
endif
	$(call assert_set SSH)
	@[ -x $(SSH) ] || (echo "$(SSH) not executable"; exit 1)
	$(call assert_set SSH_KEYGEN)
	@[ -x $(SSH_KEYGEN) ] || (echo "$(SSH_KEYGEN) not executable"; exit 1)
ifndef HOME
	$(info ERROR: You need to define the HOME environment variable pointing to your home directory)
	exit 1
endif

.PHONY: ssh\:keys
## Generate public/private ssh keys
ssh\:keys: %keys: %deps %keys:clean
ifdef SSH_DO_NOT_USE_HARNESS_KEYPAIR
	return 0
endif
ifneq ($(shell test -e $(SSH_KEY_FILE) && echo -n yes),yes)
ifndef HAS_JOSH_K_SEAL_OF_APPROVAL
	@mkdir -p $(shell dirname $(SSH_KEY_FILE))
	@$(SSH_KEYGEN) -t rsa -b 2048 -f $(SSH_KEY_FILE) -P ""
endif
endif
ifneq ($(shell test -L $(SSH_KEY_FILE_LINK) && echo -n yes),yes)
	@echo INFO: clearing out old symlinks
	rm -f $(SSH_KEY_FILE_LINK) $(SSH_KEY_FILE_LINK).pub
endif
	@echo INFO: using ssh keys located at: "$(SSH_KEY_FILE)"
	@ln -s $(SSH_KEY_FILE) $(SSH_KEY_FILE_LINK)
	@chmod 400 $(SSH_KEY_FILE_LINK)
	@ln -s $(SSH_KEY_FILE).pub $(SSH_KEY_FILE_LINK).pub
ifdef ECHO_SSH_KEYS
	@echo "public key:"
	@cat $(SSH_KEY_FILE).pub
	@echo "private key:"
	@cat $(SSH_KEY_FILE)
endif

.PHONY: ssh\:keys\:clean
## Delete ssh key links in current directory
ssh\:keys\:clean: %keys\:clean:
ifdef SSH_DO_NOT_USE_HARNESS_KEYPAIR
	return 0
endif
	@rm -f $(SSH_KEY_FILE_LINK) $(SSH_KEY_FILE_LINK).pub

.PHONY: ssh\:keys\:public
## Get the public key file used
ssh\:keys\:public: %keys\:public: %deps 
ifdef SSH_DO_NOT_USE_HARNESS_KEYPAIR
	return 1
endif
	@echo $(SSH_KEY_FILE).pub

.PHONY: ssh\:keys\:private
## Get the public key file used
ssh\:keys\:private: %keys\:private: %deps 
ifdef SSH_DO_NOT_USE_HARNESS_KEYPAIR
	return 1
endif
	@echo $(SSH_KEY_FILE)
