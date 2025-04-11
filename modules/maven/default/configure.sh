#!/bin/sh
# Configure module
set -e

# install default settings.xml file in user home
mkdir -p $HOME/.m2
ln -s /opt/jboss/container/maven/default/jboss-settings.xml $HOME/.m2/settings.xml

chown -R $USER:root $HOME/.m2
chmod -R ug+rwX $HOME/.m2
