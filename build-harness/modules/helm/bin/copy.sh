#!/bin/bash


export FROM_REPO=${1:-}
export FROM_CHART=${2:-}
export FROM_VERSION=${3:-}
export TO_REPO=${4:-}
export TO_CHART=${5:-}
export TO_VERSION=${6:-}
export ARTIFACTORY_TOKEN=${5:-}
export ARTIFACTORY_URL=${6:-na.artifactory.swg-devops.com}

if [ "$FROM_CHART-$FROM_VERSION" == "$TO_CHART-$TO_VERSION" ]; then
    curl -H "X-JFrog-Art-Api: $ARTIFACTORY_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{ \"path\": \"$FROM_CHART-$FROM_VERSION.tgz\", \"repoKey\": \"$FROM_REPO\", \"targetPath\": \"$TO_CHART-$TO_VERSION.tgz\", \"targetRepoKey\": \"$TO_REPO\" }" \
        https://$ARTIFACTORY_URL/artifactory/ui/artifactactions/copy
else
    # download chart locally
    curl '-#' -fL -H "X-JFrog-Art-Api: $ARTIFACTORY_TOKEN" \
        -o $FROM_CHART-$FROM_VERSION.tgz \
        https://$ARTIFACTORY_URL/artifactory/$FROM_REPO/$FROM_CHART-$FROM_VERSION.tgz

    # unpack
    tar xzf $FROM_CHART-$FROM_VERSION.tgz
    # update version
    $(pwd)/build-harness/vendor/helm package --version $TO_VERSION $FROM_CHART
    # remove unpacked chart dir
    rm -rf $FROM_CHART
    # remove old chart
    rm -f $FROM_CHART-$FROM_VERSION.tgz

    # upload new chart
    curl -H "X-JFrog-Art-Api: $ARTIFACTORY_TOKEN" \
        -T $TO_CHART-$TO_VERSION.tgz \
        https://$ARTIFACTORY_URL/artifactory/$TO_REPO/$TO_CHART-$TO_VERSION.tgz
    rm -f $TO_CHART-$TO_VERSION.tgz
fi