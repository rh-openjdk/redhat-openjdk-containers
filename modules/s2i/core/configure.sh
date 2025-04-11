#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)

chown -R $USER:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR

mkdir -p /deployments \
 && chmod -R "ug+rwX" /deployments \
 && chown -R $USER:root /deployments
