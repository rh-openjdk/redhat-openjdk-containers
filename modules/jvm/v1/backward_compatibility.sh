#!/bin/sh
# Configure module
set -e

# For backward compatibility
mkdir -p /opt/run-java
ln -s /opt/jboss/container/java/jvm/* /opt/run-java

chown -R jboss:root /opt/run-java
