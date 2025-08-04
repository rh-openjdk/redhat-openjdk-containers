#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D {${ARTIFACTS_DIR},}/opt/jboss/container/s2i/core/s2i-core

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

mkdir -p /usr/local/s2i \
 && chmod 775 /usr/local/s2i \
 && chown -R $USER:root /usr/local/s2i

# OPENJDK-2805
ln -s /usr/local/s2i /usr/libexec/s2i

mkdir -p /deployments \
 && chmod -R "ug+rwX" /deployments \
 && chown -R $USER:root /deployments
