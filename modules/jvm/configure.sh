#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -D -t /opt/jboss/container/java/jvm \
    ${ARTIFACTS_DIR}/opt/jboss/container/java/jvm/*
