#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

chown -R $USER:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/s2i/core/*

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

mkdir -p /deployments \
 && chmod -R "ug+rwX" /deployments \
 && chown -R $USER:root /deployments
