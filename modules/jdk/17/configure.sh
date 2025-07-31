#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

chown -R $USER:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/openjdk/jdk/*

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

# Set this JDK as the alternative in use
_arch="$(uname -i)"
alternatives --set java java-17-openjdk.${_arch}
alternatives --set javac java-17-openjdk.${_arch}
alternatives --set java_sdk_openjdk java-17-openjdk.${_arch}
alternatives --set jre_openjdk java-17-openjdk.${_arch}

# Update securerandom.source for quicker starts (must be done after removing jdk 8, or it will hit the wrong files)
JAVA_SECURITY_FILE=/usr/lib/jvm/java/conf/security/java.security
SECURERANDOM=securerandom.source
if grep -q "^$SECURERANDOM=.*" $JAVA_SECURITY_FILE; then
    sed -i "s|^$SECURERANDOM=.*|$SECURERANDOM=file:/dev/urandom|" $JAVA_SECURITY_FILE
else
    echo $SECURERANDOM=file:/dev/urandom >> $JAVA_SECURITY_FILE
fi
