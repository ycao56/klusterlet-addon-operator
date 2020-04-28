#!/bin/bash
###############################################################################
# (c) Copyright IBM Corporation 2019, 2020. All Rights Reserved.
# Note to U.S. Government Users Restricted Rights:
# U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
# Licensed Materials - Property of IBM
# 
# Copyright (c) 2020 Red Hat, Inc.
###############################################################################
# PARAMETERS
# $1 - Final image name and tag to be produced
CURR_FOLDER_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

echo "Building operator"
echo "--IMAGE: $DOCKER_IMAGE"
echo "--TAG: $DOCKER_BUILD_TAG"
echo DOCKER_BUILD_OPTS: $DOCKER_BUILD_OPTS
docker build "$CURR_FOLDER_PATH/../" \
$DOCKER_BUILD_OPTS \
-t $DOCKER_IMAGE:$DOCKER_BUILD_TAG \
-f "$CURR_FOLDER_PATH/Dockerfile"

if [ ! -z "$1" ]; then
    echo "Retagging image as $1"
    docker tag $DOCKER_IMAGE:$DOCKER_BUILD_TAG $1
fi
