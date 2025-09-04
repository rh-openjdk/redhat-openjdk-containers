#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -D {${ARTIFACTS_DIR},}/usr/libexec/s2i/save-artifacts
install -m 0644 -D -t /opt/jboss/container/maven/s2i \
    ${ARTIFACTS_DIR}/opt/jboss/container/maven/s2i/*
