#!/bin/bash

set -e

if [ ! -f test/coverage/cover.out ]; then
    echo "Coverage file test/coverage/cover.out does not exist"
    exit 0
fi

COVERAGE=$(go tool cover -func=test/coverage/cover.out | grep "total:" | awk '{ print $3 }' | sed 's/[][()><%]/ /g')

echo "-------------------------------------------------------------------------"
echo "TOTAL COVERAGE IS ${COVERAGE}%"
echo "-------------------------------------------------------------------------"

go tool cover -html=test/coverage/cover.out -o=test/coverage/cover.html
