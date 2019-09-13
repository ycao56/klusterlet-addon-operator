export BUILD_HARNESS_PATH ?= $(shell 'pwd')
export BUILD_HARNESS_OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
export BUILD_HARNESS_ARCH ?= $(shell uname -m | sed 's/x86_64/amd64/g')
export SELF ?= make
export TMP ?= /tmp

export GITHUB_USER ?= 
export GITHUB_TOKEN ?= 

# Import Makefiles into current context
include $(BUILD_HARNESS_PATH)/Makefile.*
include $(BUILD_HARNESS_PATH)/modules/*/bootstrap.Makefile*
include $(BUILD_HARNESS_PATH)/modules/*/Makefile*
