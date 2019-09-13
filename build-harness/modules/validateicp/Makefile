GIT ?= $(shell which git)
ICP_VALIDATION_REPO ?= "https://github.com/ibm-cloud-architecture/icp-validation-tests.git"
ICP_VALIDATION_BRANCH ?= "master"
ICP_VALIDATION_DIR ?= $(BUILD_HARNESS_PATH)/vendor/validateicp

.PHONY: validateicp\:init
## Get the validation code
validateicp\:init:
ifeq ($(shell test -d $(ICP_VALIDATION_DIR) && echo -n yes || echo -n no),yes)
	$(info ICP Validation tests already exists in $(ICP_VALIDATION_DIR))
else
	$(GIT) clone -b $(ICP_VALIDATION_BRANCH) $(ICP_VALIDATION_REPO) $(ICP_VALIDATION_DIR)
endif


.PHONY: validateicp\:runall
## Run all validation tests
validateicp\:runall: %validateicp\:runall: %validateicp:init
	$(ICP_VALIDATION_DIR)/run.sh -a
