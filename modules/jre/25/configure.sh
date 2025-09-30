#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D {${ARTIFACTS_DIR},}${JBOSS_CONTAINER_OPENJDK_JRE_MODULE}/jvm-options
