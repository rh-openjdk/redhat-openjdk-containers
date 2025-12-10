#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D {${ARTIFACTS_DIR},}/etc/yum.repos.d/epel.repo
install -m 0644 -D {${ARTIFACTS_DIR},}/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
