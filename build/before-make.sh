#!/bin/bash

set -e

# Create link to pre-commit hook
if [[ ! -e .git/hooks/pre-commit ]]; then
    ln -sf ../../build/git-hooks/pre-commit .git/hooks/pre-commit
fi

if [[ ! -e .build-harness ]]; then
    curl -fso .build-harness -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3.raw" "https://raw.github.ibm.com/ICP-DevOps/build-harness/master/templates/Makefile.build-harness"
fi
