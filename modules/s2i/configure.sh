#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -D ${ARTIFACTS_DIR}/usr/libexec/s2i/* /usr/libexec/s2i
install -m 0644 -D -t /opt/jboss/container/java/s2i \
    ${ARTIFACTS_DIR}/opt/jboss/container/java/s2i/*

install -m 0644 -D {${ARTIFACTS_DIR},}/opt/jboss/container/java/s2i/s2i-core

mkdir -p /deployments \
 && chmod -R "ug+rwX" /deployments \
 && chown -R $USER:root /deployments
