#!/bin/bash -e
###############################################################################
# (c) Copyright IBM Corporation 2019, 2020. All Rights Reserved.
# Note to U.S. Government Users Restricted Rights:
# U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
# Licensed Materials - Property of IBM
# 
# Copyright (c) 2020 Red Hat, Inc.
###############################################################################
export GO111MODULE=on
echo ">>> Building Helm Operator Image"
CURR_FOLDER_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

pushd $CURR_FOLDER_PATH/../operator-sdk
git checkout .

echo ">>> >>> Running make tidy"
make tidy || echo 'make tidy failed, skipping'

if [ $ARCH = x86_64 ];
then
  ARCH=amd64
  echo 'use amd64'
fi

echo ">>> >>> Patching Makefile"
sed -i'.bak' s/x86_64/$ARCH/g Makefile 
sed -i'.bak2' s/amd64/$ARCH/g Makefile && rm Makefile.bak2

echo ">>> >>> build helm-operator binary"
export GOARCH=$ARCH
export GOOS=linux
make build/operator-sdk-dev-$ARCH-linux-gnu

mv Makefile.bak Makefile
echo ">>> >>> Make custom helm-operator image"
source hack/lib/test_lib.sh

ROOTDIR="$(pwd)"
GOTMP="$(mktemp -d)"
trap_add 'rm -rf $GOTMP' EXIT
BASEIMAGEDIR="$GOTMP/helm-operator"
mkdir -p "$BASEIMAGEDIR"
unset GOOS
go build -o $BASEIMAGEDIR/scaffold-helm-image ./hack/image/helm/scaffold-helm-image.go

# build operator binary and base image
pushd "$BASEIMAGEDIR"
./scaffold-helm-image

mkdir -p build/_output/bin/
cp $ROOTDIR/build/operator-sdk-dev-${ARCH}-linux-gnu build/_output/bin/helm-operator

cat build/Dockerfile
sed -i'.bak' 's/ubi8\/ubi-minimal:latest/ubi8\/ubi-minimal:8.1-398/g' build/Dockerfile && rm build/Dockerfile.bak

operator-sdk build quay.io/operator-framework/helm-operator:dev

docker tag quay.io/operator-framework/helm-operator:dev quay.io/operator-framework/helm-operator:v0.16.0

echo ">>> Done Building Helm Operator Image"
popd
