#!/bin/bash

set -e

_script_dir=$(dirname "$0")
mkdir -p test/coverage
echo 'mode: atomic' > test/coverage/cover.out
echo '' > test/coverage/cover.tmp
echo -e "${GOPACKAGES// /\\n}" | xargs -n1 -I{} $_script_dir/test-package.sh {} ${GOPACKAGES// /,}
