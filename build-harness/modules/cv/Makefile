CURL := $(shell which curl)

CV_VERSION ?= 1.4.5
CV_PLATFORM ?= $(BUILD_HARNESS_OS)
CV_ARCH ?= $(BUILD_HARNESS_ARCH)
CV_URL ?= https://api.github.ibm.com/repos/IBMPrivateCloud/content-verification/releases/assets/
CV_FILE ?= cv-$(CV_PLATFORM)-$(CV_ARCH).tar.gz
CV ?= $(BUILD_HARNESS_PATH)/vendor/cv

# Here, we're processing the github release asset json to correlate the friendly name with the asset ID
# This is all because we can't use the browser URL to download because... W3ID
CV_JQ_QUERY ?= "-r --arg CV_FILE $(CV_FILE) '.assets[] | select(.browser_download_url | contains(\"$(CV_FILE)\")) | .id'"

.PHONY: cv\:install
## Install the content verification tool (aka cv)
cv\:install: %install:
# Given the name of the content-verification download file, go ask github for the asset number so we can get it via the API.
	@[ -x $(CV) ] || ( \
		CV_ASSET=`curl -s -u $(GITHUB_USER):$(GITHUB_TOKEN) https://api.github.ibm.com/repos/IBMPrivateCloud/content-verification/releases/tags/v$(CV_VERSION) | $(SELF) jq:search JQ_SEARCH_VAR=$(CV_JQ_QUERY) | grep -v make` && \
		echo "Installing cv $(CV_VERSION) $(CV_FILE) from $(CV_URL)$$CV_ASSET" && \
		curl '-#' -fL -s -H "Accept:application/octet-stream" -u $(GITHUB_USER):$(GITHUB_TOKEN) -o $(TMP)/$(CV_FILE) $(CV_URL)$$CV_ASSET && \
		tar -xf $(TMP)/$(CV_FILE) -C $(BUILD_HARNESS_PATH)/vendor && \
		chmod +x $(CV) && \
		rm $(TMP)/$(CV_FILE) && \
		$(CV) version \
		)

CV_RUN_ARGS ?= help

.PHONY: cv\:run
## Run the cv tool; set $CV_RUN_ARGS to the arguments you want to pass.  Requires $GITHUB_USER and $GITHUB_TOKEN for access to download tool.
cv\:run: %cv\:run: %cv:install
	@$(CV) $(CV_RUN_ARGS)
