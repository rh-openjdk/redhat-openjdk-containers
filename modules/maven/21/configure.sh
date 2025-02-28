#!/bin/sh
set -e

# This file is shipped by a Maven package and sets JAVA_HOME to
# an OpenJDK-specific path. This causes problems for OpenJ9 containers
# as the path is not correct for them.  We don't need this in any of
# the containers because we set JAVA_HOME in the container metadata.
# Blank the file rather than removing it, to avoid a warning message
# from /usr/bin/mvn.
if [ -f /etc/java/maven.conf ]; then
  :> /etc/java/maven.conf
fi
