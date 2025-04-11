#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

chown -R $USER:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

# Set this JDK as the alternative in use
_arch="$(uname -i)"
alternatives --set java java-1.8.0-openjdk.${_arch}
