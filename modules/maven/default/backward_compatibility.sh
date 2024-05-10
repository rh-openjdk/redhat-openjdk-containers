#!/bin/sh
# Configure module
set -e

# For backward compatibility
mkdir -p /usr/local/s2i
ln -s /opt/jboss/container/maven/default/maven.sh /usr/local/s2i/common.sh
chown -h jboss:root /usr/local/s2i/common.sh
