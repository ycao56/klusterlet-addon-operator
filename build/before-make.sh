#!/bin/bash
# Licensed Materials - Property of IBM
# 5737-E67
# (C) Copyright IBM Corporation 2016, 2019 All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.



# Create link to pre-commit hook
if [[ ! -e .git/hooks/pre-commit ]]; then
    ln -sf ../../build/git-hooks/pre-commit .git/hooks/pre-commit
fi

# if [[ ! -e .build-harness ]]; then
curl -fso .build-harness -H "Authorization: token ${GITHUB_TOKEN}" -H "Accept: application/vnd.github.v3.raw" "https://raw.github.ibm.com/ICP-DevOps/build-harness/master/templates/Makefile.build-harness"
# fi