
GO := $(shell which go)
GO_MOD = $(BUILD_HARNESS_PATH)/modules/go
GOPACKAGES ?= $(shell go list ./... 2>/dev/null | grep -v /vendor/ | grep -v /internal | grep -v /build | grep -v /test)

.PHONY: go\:test
## Run all project tests
go\:test: export GOPACKAGES := ${GOPACKAGES}
go\:test:
ifeq (, $(shell which patter))
	@$(GO) get -u github.com/apg/patter
endif
ifeq (, $(shell which gocovmerge))
	@$(GO) get -u github.com/wadey/gocovmerge
endif
	@$(GO_MOD)/test.sh
	@$(GO_MOD)/calculate-coverage.sh

.PHONY: go\:lint
## Runs a set of golang linting tools
go\:lint: validate-gometalinter
	@echo "Running linting tools ..."
	@gometalinter --disable-all --deadline=600s --enable=golint --enable=vet --enable=ineffassign --enable=staticcheck --enable=goimports --enable=misspell --tests --vendor ./...

.PHONY: go\:fmt
## Runs gofmt and applies changes across all go files
go\:fmt:
	@echo "Running gofmt ..."
	@$(GO_MOD)/gofmt.sh

.PHONY: go\:imports
## Fix go imports in offending files, generally used after refactoring packages
go\:imports: validate-gometalinter
    @gometalinter --disable-all --enable=goimports --tests --vendor ./... 2>&1 | grep "is not goimported" | cut -d ':' -f 1 | xargs -I{} goimports -w {}

.PHONY: go\:check
## Runs a set of required checks
go\:check: %go\:check: %go:lint %go:ossc:check

.PHONY: go\:copyright\:check
## Runs check to validate all files have the correct copyright header
go\:copyright\:check:
	@echo "Running copyright check ..."
	@$(GO_MOD)/copyright-check.sh

.PHONY: go\:copyright\:fix
## Adds valid copyright header to .go files with invalid or missing header
go\:copyright\:fix:
	@echo "Generating copyright headers ..."
	@$(GO_MOD)/copyright-check.sh fix

.PHONY: go\:ossc\:check
## Runs check to validate OPENSOURCE file is up to date
go\:ossc\:check: validate-ossc
	@echo "Running opensource check ..."
	@ossc --check

.PHONY: go\:ossc
## Generates new OPENSOURCE file
go\:ossc: validate-ossc
	@echo "Generating OPENSOURCE file ..."
	@ossc

.PHONY: go\:ossc\:csv
## Generate OSSC csv file
go\:ossc\:csv: validate-ossc
	@echo "Generating ossc file ..."
	@ossc --csv

.PHONY: go\:mocks
## Generate golang internal mock files
go\:mocks::
ifeq (, $(shell which mockery))
	@$(GO) get -u github.com/vektra/mockery/...
endif
	@echo "Generating mock files ..."
	@$(GO_MOD)/generate-mocks.sh

.PHONY: go\:clean
## Remove generated build and test files
go\:clean:
	-@rm -rf test/out
	-@rm -rf test/coverage
	-@rm -rf .build-docker
	-@rm -rf .build
	-@rm -rf bin

validate-gometalinter:
ifeq (, $(shell which gometalinter))
	@$(GO) get -u github.com/alecthomas/gometalinter
	gometalinter --install
endif

validate-ossc:
ifeq (, $(shell which ossc))
	@$(GO) get -u github.ibm.com/IBMPrivateCloud/armada-opensource-lib/ossc
endif
