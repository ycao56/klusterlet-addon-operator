#!/bin/bash

rm -rf internal/mocks

_base_package="$(go list -e .)/"
_base_package_path="$GOPATH/$_base_package"

if [ -z "$GOPACKAGES" ]; then
    GOPACKAGES=$(go list ./... | grep -v /vendor | grep -v /internal | grep -v /build | grep -v /test)
fi

for _package in ${GOPACKAGES[@]}; do
    _package_path="$GOPATH/$_package"
    _relative_package_path=${_package/$_base_package/}
    _relative_package_path=${_relative_package_path#"/"}
    _package_name=${_package##*/}
    echo "Mocking interfaces in package $_package"
    $GOPATH/bin/mockery -name='.*' -dir=$_relative_package_path -output=internal/mocks/$_relative_package_path -outpkg=$_package_name -case=underscore | grep -v 'Unable to find'
done

# we need a line after the last mockery call so this script doesn't fail if no interfaces are found in the last package
echo ""