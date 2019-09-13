GIT:= $(shell which git)
VAGRANT_GITHUB_USER ?= "tpouyer%40us.ibm.com"
VAGRANT_GITHUB_TOKEN ?= e9a93be4174d0556ac0672d7fd582e54e34c0947
VAGRANT_LXD_SERVER_GIT_PROJECT ?= "https://$(VAGRANT_GITHUB_USER):$(VAGRANT_GITHUB_TOKEN)@github.ibm.com/ICP-DevOps/vagrant_lxd_server.git"
VAGRANT_BRANCH ?= master
VAGRANT_DIR ?= .vagrant/
VAGRANT:= $(shell which vagrant)

vagrant\:up:
	rm -rf $(VAGRANT_DIR)
	@$(GIT) clone -b $(VAGRANT_BRANCH) $(VAGRANT_LXD_SERVER_GIT_PROJECT) $(VAGRANT_DIR)
	export VAGRANT_CWD=$(VAGRANT_DIR); $(VAGRANT) up

vagrant\:destroy:
ifneq ("$(wildcard $(VAGRANT_DIR))","")
	@export VAGRANT_CWD=$(VAGRANT_DIR); $(VAGRANT) destroy -f
endif

vagrant\:halt:
ifneq ("$(wildcard $(VAGRANT_DIR))","")
	@export VAGRANT_CWD=$(VAGRANT_DIR); $(VAGRANT) halt
endif