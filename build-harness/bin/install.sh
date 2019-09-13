#!/bin/bash
export BUILD_HARNESS_ORG=${1:-ICP-DevOps}
export BUILD_HARNESS_PROJECT=${2:-build-harness}
export BUILD_HARNESS_BRANCH=${3:-master}
export GITHUB_USER=${4}
export GITHUB_TOKEN=${5}
# export GITHUB_REPO="git@github.ibm.com:${BUILD_HARNESS_ORG}/${BUILD_HARNESS_PROJECT}.git"
export GITHUB_REPO="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.ibm.com/${BUILD_HARNESS_ORG}/build-harness.git"

if [ -d "$BUILD_HARNESS_PROJECT" ]; then
  echo "Removing existing $BUILD_HARNESS_PROJECT"
  rm -rf "$BUILD_HARNESS_PROJECT"
fi

echo "Cloning ${GITHUB_REPO}#${BUILD_HARNESS_BRANCH}..."
git clone -b $BUILD_HARNESS_BRANCH $GITHUB_REPO
