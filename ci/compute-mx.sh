#!/bin/bash

set -euo pipefail

yq -o json axis.yaml | jq -c 'include "ci/compute-mx"; compute_mx(.)'

# MATRIX=$(yq -o json '.' axis.yaml | jq -c)
# echo "MATRIX=${MATRIX}" | tee --append ${GITHUB_OUTPUT:-/dev/null}
