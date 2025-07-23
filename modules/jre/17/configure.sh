#!/bin/sh
set -e

# Set this JDK as the alternative in use
_arch="$(uname -i)"
alternatives --set java java-17-openjdk.${_arch}
