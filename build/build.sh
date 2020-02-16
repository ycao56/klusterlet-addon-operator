#!/bin/bash

# PARAMETERS
# $1 - Final image name and tag to be produced

# maybe bring this back when we're doing multi arch builds
# this builds the base helm operator image
# $BUILD_DIR/build-helm-operator-image.sh

echo "Building operator"
echo "--IMAGE: $DOCKER_IMAGE"
echo "--TAG: $DOCKER_BUILD_TAG"
operator-sdk build $DOCKER_IMAGE:$DOCKER_BUILD_TAG --image-build-args "$DOCKER_BUILD_OPTS"

if [ ! -z "$1" ]; then
    echo "Retagging image as $1"
    docker tag $DOCKER_IMAGE:$DOCKER_BUILD_TAG $1
fi
