#!/bin/bash
# Licensed Materials - Property of IBM
# IBM Confidential
# OCO Source Materials
# (C) Copyright IBM Corporation 2016, 2019 All Rights Reserved
# The source code for this program is not published or otherwise divested of its trade secrets, irrespective of what has been deposited with the U.S. Copyright Office.


export GO111MODULE=on
echo ">>> Building Helm Operator Image"
echo ">>> >>> Downloading source code"
go get -d github.com/operator-framework/operator-sdk

pushd $GOPATH/src/github.com/operator-framework/operator-sdk

echo ">>> >>> Checking out version 0.9.0"
git checkout v0.9.0

echo ">>> >>> Running make tidy"
make tidy

echo ">>> >>> Patching Makefile"
sed -i s/x86_64/$ARCH/g Makefile
sed -i s/amd64/$ARCH/g Makefile

echo ">>> >>> build helm-operator binary"
export GOARCH=$ARCH
export GOOS=linux
make build/operator-sdk-dev-$ARCH-linux-gnu

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

sed -i 's/ubi-minimal:latest/ubi-minimal:7.7-238/g' build/Dockerfile

operator-sdk build quay.io/operator-framework/helm-operator:dev

docker tag quay.io/operator-framework/helm-operator:dev quay.io/operator-framework/helm-operator:v0.10.1

echo ">>> Done Building Helm Operator Image"
popd
