#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D {${ARTIFACTS_DIR},}/opt/jboss/container/openjdk/jdk/jvm-options
