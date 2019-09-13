PYTHON3 := $(shell which python3)
GREP := $(shell which grep)
PIP3 := $(shell which pip3)
LOG_DIR := $(BUILD_HARNESS_PATH)/modules/log
LOG_RUNNER_DIR := $(LOG_DIR)/logrunner
FEATURE_FLAG_DIR := $(LOG_DIR)/feature-flags
LOG_SCAN_INPUT_FILE ?= $(LOG_DIR)/data/inputfile.dict
LOG_FILE ?= 
LOG_TEST_OUTPUT_DIR ?=
LOG_VENV_DIR ?= $(LOG_RUNNER_DIR)/logrunner-pyvenv
LOG_VENV_ACTIVATE ?= $(LOG_VENV_DIR)/bin/activate
LOGGER_GITHUB_USER ?= $(GITHUB_USER)
LOGGER_GITHUB_TOKEN ?= $(GITHUB_TOKEN)
LOGGER_GIT_TF_DEPLOY_PROJECT ?= "https://$(LOGGER_GITHUB_USER):$(LOGGER_GITHUB_TOKEN)@github.ibm.com/ICP-DevOps/cicd-travis-logger.git"
LOGGER_FLAG_PROJECT ?= "https://$(LOGGER_GITHUB_USER):$(LOGGER_GITHUB_TOKEN)@github.ibm.com/ICP-DevOps/feature-flags.git"
LOGGER_GIT_TF_DEPLOY_BRANCH ?= master
LOGGER_GIT_FLAG_BRANCH ?= master

LOG_CREATE_VENV ?= true

ifdef HAS_JOSH_K_SEAL_OF_APPROVAL
ifndef JENKINS_HOME
	LOG_VENV_ACTIVATE = ~/virtualenv/python3.6/bin/activate
	LOG_CREATE_VENV = false
endif
endif
ifeq ($(BUILD_HARNESS_ARCH),s390x)
	LOG_VENV_ACTIVATE = $(LOG_VENV_DIR)/bin/activate
	LOG_CREATE_VENV = true
endif

.PHONY: log\:clone
log\:clone: %clone:
	@rm -rf $(LOG_RUNNER_DIR)
	@$(GIT) clone -b $(LOGGER_GIT_TF_DEPLOY_BRANCH) $(LOGGER_GIT_TF_DEPLOY_PROJECT) $(LOG_RUNNER_DIR)
	@$(GIT) clone -b $(LOGGER_GIT_TF_DEPLOY_BRANCH) $(LOGGER_FLAG_PROJECT) $(FEATURE_FLAG_DIR)

.PHONY: log\:init
## Initialize logging framework and log build start
log\:init: %init: %clone
ifeq ($(LOG_CREATE_VENV),true)
	$(PYTHON3) -m venv $(LOG_VENV_DIR)
	$(eval SERVER := $(shell cat $(FEATURE_FLAG_DIR)/cicd-travis-logger/server))
	$(eval PORT := $(shell cat $(FEATURE_FLAG_DIR)/cicd-travis-logger/port))
	@sed -i -e "1s/^/ export $(SERVER); export $(PORT);/" "$(LOG_VENV_ACTIVATE)"
endif
	@source $(LOG_VENV_ACTIVATE); \
	pip3 install --upgrade pip > /dev/null; \
	python3 -V; \
	pip3 -V; \
	pip3 install -r $(LOG_RUNNER_DIR)/requirements.txt; \
	python3 $(LOG_RUNNER_DIR)/logrunner.py begin

.PHONY: log\:test
## Log test results (PARAMETER: LOG_TEST_OUTPUT_DIR=$$path-to-test-output-directory$$)
log\:test:
	@source $(LOG_VENV_ACTIVATE); \
	python3 $(LOG_RUNNER_DIR)/logrunner.py tests -d $(LOG_TEST_OUTPUT_DIR)

.PHONY: log\:pass
## Log build pass
log\:pass:
	@source $(LOG_VENV_ACTIVATE); \
	python3 $(LOG_RUNNER_DIR)/logrunner.py end --success

.PHONY: log\:fail
## Log build failure
log\:fail:
	@source $(LOG_VENV_ACTIVATE); \
	python3 $(LOG_RUNNER_DIR)/logrunner.py end --fail

.PHONY: log\:scan
## Log build failure (LOG_FILE=the path to the log file to scan)
log\:scan:
	$(GREP) -i -E -nr -f $(LOG_SCAN_INPUT_FILE) $(LOG_FILE)
