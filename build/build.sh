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

# maybe bring this back when we're doing multi arch builds
# this builds the base helm operator image
$BUILD_DIR/build-helm-operator-image.sh

echo "Building operator"
echo "--IMAGE: $DOCKER_IMAGE"
echo "--TAG: $DOCKER_BUILD_TAG"
operator-sdk build $DOCKER_IMAGE:$DOCKER_BUILD_TAG --image-build-args "$DOCKER_BUILD_OPTS"

if [ ! -z "$1" ]; then
    echo "Retagging image as $1"
    docker tag $DOCKER_IMAGE:$DOCKER_BUILD_TAG $1
fi
