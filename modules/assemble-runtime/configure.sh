#!/bin/bash
set -euo pipefail

mkdir -p /usr/local/s2i
cp {$(dirname $0)/artifacts,}/usr/local/s2i/assemble-runtime
