# Copyright (c) 2020 Red Hat, Inc.
# Copyright Contributors to the Open Cluster Management project

#!/bin/bash
###############################################################################
# (c) Copyright IBM Corporation 2019, 2020. All Rights Reserved.
# Note to U.S. Government Users Restricted Rights:
# U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
# Licensed Materials - Property of IBM
###############################################################################
set -e

# Create link to pre-commit hook
if [[ ! -e .git/hooks/pre-commit ]]; then
    ln -sf ../../build/git-hooks/pre-commit .git/hooks/pre-commit
fi
