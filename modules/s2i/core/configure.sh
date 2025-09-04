#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D {${ARTIFACTS_DIR},}/opt/jboss/container/s2i/core/s2i-core

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

mkdir -p /deployments \
 && chmod -R "ug+rwX" /deployments \
 && chown -R $USER:root /deployments
