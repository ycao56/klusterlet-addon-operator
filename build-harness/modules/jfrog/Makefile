CURL := $(shell which curl)
TMP ?= /tmp
JFROG_VERSION ?= 1.25.0
JFROG_PLATFORM ?= $(shell echo $(BUILD_HARNESS_OS) | sed 's/darwin/mac/g')
JFROG_ARCH ?= $(shell echo $(BUILD_HARNESS_ARCH) | sed 's/amd64/amd64/g')
JFROG_URL ?= https://api.bintray.com/content/jfrog/jfrog-cli-go/$(JFROG_VERSION)/jfrog-cli-$(JFROG_PLATFORM)-386/jfrog?bt_package=jfrog-cli-$(JFROG_PLATFORM)-386
JFROG ?= $(BUILD_HARNESS_PATH)/vendor/jfrog


.PHONY: jfrog\:install
## Install jfrog cli
jfrog\:install: %install:
	@[ -x $(JFROG) ] || ( \
		echo "Installing JFrog cli $(JFROG_VERSION) ($(JFROG_PLATFORM)$(JFROG_ARCH)) from $(JFROG_URL)" && \
		curl '-#' -fL -o $(JFROG) $(JFROG_URL) && \
		chmod +x $(JFROG) \
		)
	$(JFROG) --version