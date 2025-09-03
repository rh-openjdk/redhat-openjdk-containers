#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D -t /opt/jboss/container/java/proxy \
    ${ARTIFACTS_DIR}/opt/jboss/container/java/proxy/*
