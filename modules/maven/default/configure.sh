#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D {${ARTIFACTS_DIR},}/opt/jboss/container/maven/default/maven.sh
# 0664: OPENJDK-4024
install -m 0664 -D {${ARTIFACTS_DIR},}/opt/jboss/container/maven/default/jboss-settings.xml

# install default settings.xml file in user home
mkdir -p $HOME/.m2
ln -s /opt/jboss/container/maven/default/jboss-settings.xml $HOME/.m2/settings.xml

chown -R $USER:root $HOME/.m2
chmod -R ug+rwX $HOME/.m2
