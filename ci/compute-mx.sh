#!/bin/bash

set -euo pipefail

PR_NUM=${PR_NUM:-""}
BUILD_TYPE=${BUILD_TYPE:-""}

yq -o json axis.yaml | jq -c 'include "ci/compute-mx"; compute_mx(.)' --arg pr_num "${PR_NUM}" --arg build_type "${BUILD_TYPE}"

