#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

install -m 0644 -D -t /opt/jboss/container/maven/default \
    ${ARTIFACTS_DIR}/opt/jboss/container/maven/default/*

MAVEN_VERSION_SQUASHED=${MAVEN_VERSION/./}

# pull in specific maven version to serve as default
ln -s /opt/jboss/container/maven/${MAVEN_VERSION_SQUASHED}/* /opt/jboss/container/maven/default

# install default settings.xml file in user home
mkdir -p $HOME/.m2
ln -s /opt/jboss/container/maven/default/jboss-settings.xml $HOME/.m2/settings.xml

chown -R $USER:root $HOME/.m2
chmod -R ug+rwX $HOME/.m2
