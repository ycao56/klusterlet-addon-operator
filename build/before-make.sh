#!/bin/bash

set -e

# Create link to pre-commit hook
if [[ ! -e .git/hooks/pre-commit ]]; then
    ln -sf ../../build/git-hooks/pre-commit .git/hooks/pre-commit
fi
