#!/bin/sh
# run scripts for images built using openshift-openjdk-s2i-1.8
set -u
set -e

ln -s /opt/jboss/container/java/run /opt/run-java

chown -h jboss:root /opt/run-java/run