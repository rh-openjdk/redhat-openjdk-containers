#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

chown -R jboss:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/java/run/*

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

mkdir -p /deployments/data \
 && chmod -R "ug+rwX" /deployments/data \
 && chown -R jboss:root /deployments/data
