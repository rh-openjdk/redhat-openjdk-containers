#!/bin/bash
set -euo pipefail

mkdir -p /licenses
cp -al /usr/lib/jvm/java/legal /licenses/openjdk
