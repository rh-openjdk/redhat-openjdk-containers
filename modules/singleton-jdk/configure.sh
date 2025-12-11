#!/bin/bash
set -ueo pipefail
set -x

if [ -z "$JAVA_VERSION" ]; then
  echo "JAVA_VERSION needs to be defined to use this module" >&2
  exit 1
fi
if [ -z "$JAVA_VENDOR" ]; then
  echo "JAVA_VENDOR needs to be defined to use this module" >&2
  exit 1
fi

# java-latest/EPEL does not follow the pattern expected
if [ "$JAVA_VENDOR" = "epel" ]; then
  JAVA_VERSION=latest
  JAVA_VENDOR=openjdk
fi

# Clean up any java-* packages that have been installed that do not match
# our stated JAVA_VERSION-JAVA_VENDOR (e.g.: 11-openjdk; 1.8.0-openj9)
rpm -e --nodeps $(rpm -qa java-* | grep -v "^java-${JAVA_VERSION}-${JAVA_VENDOR}")

# sanity check: there should still be a java installed
command -v java
