#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D {${ARTIFACTS_DIR},}/opt/jboss/container/openjdk/jre/jvm-options

# Set this JDK as the alternative in use
_arch="$(uname -i)"
alternatives --set java java-1.8.0-openjdk.${_arch}
