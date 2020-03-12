#!/bin/bash

export GO111MODULE=on
echo ">>> Building Helm Operator Image"
CURR_FOLDER_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
git checkout $CURR_FOLDER_PATH/../operator-sdk
pushd $CURR_FOLDER_PATH/../operator-sdk


echo ">>> >>> Running make tidy"
make tidy

if [ $ARCH = x86_64 ];
then
  ARCH=amd64
  echo 'use amd64'
fi

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

sed -i 's/ubi7\/ubi-minimal:latest/ubi8\/ubi-minimal:8.1-398/g' build/Dockerfile
# ^ this mechanism was not working before
# >>> >>> Make custom helm-operator image
# /tmp/tmp.pPiHmdubpz/helm-operator ~/gopath/src/github.com/operator-framework/operator-sdk ~/gopath/src/github.ibm.com/IBMPrivateCloud/klusterlet-component-operator
# INFO[0000] Created build/Dockerfile
# INFO[0000] Created bin/entrypoint
# INFO[0000] Created bin/user_setup
# INFO[0000] Building OCI image quay.io/operator-framework/helm-operator:dev
# Sending build context to Docker daemon  116.2MB
# Step 1/7 : FROM registry.access.redhat.com/ubi7/ubi-minimal:8.1-398
# error parsing HTTP 404 response body: invalid character 'F' looking for beginning of value: "File not found.\""
# Error: failed to output build image quay.io/operator-framework/helm-operator:dev: (failed to exec []string{"docker", "build", "-f", "build/Dockerfile", "-t", "quay.io/operator-framework/helm-operator:dev", "."}: exit status 1)
# Usage:
#   operator-sdk build <image> [flags]

operator-sdk build quay.io/operator-framework/helm-operator:dev

docker tag quay.io/operator-framework/helm-operator:dev quay.io/operator-framework/helm-operator:v0.9.0

echo ">>> Done Building Helm Operator Image"
popd
