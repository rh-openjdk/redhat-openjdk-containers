#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

# configure artifact permissions
chown -R $USER:root $ARTIFACTS_DIR
chmod -R ug+rwX $ARTIFACTS_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/maven/default/maven.sh

# install artifacts
pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

MAVEN_VERSION_SQUASHED=${MAVEN_VERSION/./}

# pull in specific maven version to serve as default
ln -s /opt/jboss/container/maven/${MAVEN_VERSION_SQUASHED}/* /opt/jboss/container/maven/default
chown -h $USER:root /opt/jboss/container/maven/default/*

# install default settings.xml file in user home
mkdir -p $HOME/.m2
ln -s /opt/jboss/container/maven/default/jboss-settings.xml $HOME/.m2/settings.xml

chown -R $USER:root $HOME/.m2
chmod -R ug+rwX $HOME/.m2
