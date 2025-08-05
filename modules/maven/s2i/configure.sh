#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -D ${ARTIFACTS_DIR}/usr/local/s2i/* /usr/local/s2i
install -m 0644 -D -t /opt/jboss/container/maven/s2i \
    ${ARTIFACTS_DIR}/opt/jboss/container/maven/s2i/*
