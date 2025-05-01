#!/bin/sh
set -e

# OPENJDK-2805
ln -s /usr/local/s2i /usr/libexec/s2i

mkdir -p /deployments \
 && chmod -R "ug+rwX" /deployments \
 && chown -R $USER:root /deployments
