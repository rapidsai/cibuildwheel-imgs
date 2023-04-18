#!/usr/bin/env bash

MATRIX=$(yq -o json '.' axis_cibw.yaml | jq -c)
echo "MATRIX=${MATRIX}" | tee --append ${GITHUB_OUTPUT:-/dev/null}
