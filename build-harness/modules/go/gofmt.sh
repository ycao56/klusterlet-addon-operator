#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

find_files() {
  find . -not \( \
      \( \
        -wholename './output' \
        -o -wholename './.git' \
        -o -wholename './bin/' \
        -o -wholename './build' \
        -o -wholename './build-harness' \
        -o -wholename './configs' \
        -o -wholename './docs' \
        -o -wholename './internal/mocks' \
        -o -wholename '*/vendor/*' \
      \) -prune \
    \) -name '*.go'
}

GOFMT="gofmt -s -w"
find_files | xargs ${GOFMT}
