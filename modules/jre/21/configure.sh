#!/bin/sh
# Configure module
set -e

# Set this JDK as the alternative in use
_arch="$(uname -i)"
alternatives --set java java-21-openjdk.${_arch}
