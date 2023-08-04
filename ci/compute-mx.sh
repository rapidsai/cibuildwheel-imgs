#!/bin/bash

set -euo pipefail

export PR_NUM=34 #"${GITHUB_REF_NAME##*/}"
export BUILD_TYPE="branch"

yq -o json axis.yaml | jq -c 'include "ci/compute-mx"; compute_mx(.)' --arg pr_num "${PR_NUM}" --arg build_type "${BUILD_TYPE}"


