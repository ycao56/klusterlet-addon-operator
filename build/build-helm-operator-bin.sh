
#!/bin/bash -e
###############################################################################
# Copyright (c) 2020 Red Hat, Inc.
###############################################################################
set -e
export GO111MODULE=on
CURR_FOLDER_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

pushd $CURR_FOLDER_PATH/../operator-sdk

echo ">>> Building helm-operator binary"
export GOARCH=amd64
export GOOS=linux
make build/operator-sdk-dev-${GOARCH}-linux-gnu

mkdir -p build/_output/bin/
cp $(pwd)/build/operator-sdk-dev-${GOARCH}-linux-gnu build/_output/bin/helm-operator

echo ">>> Done building helm-operator binary"

popd

echo ">>> Copying operator-sdk build/_output"
cp $CURR_FOLDER_PATH/../operator-sdk/build/_output/bin/helm-operator $CURR_FOLDER_PATH/../build/bin/

echo ">>> Listing build/bin"
ls $CURR_FOLDER_PATH/../build/bin

echo ">>> Done"