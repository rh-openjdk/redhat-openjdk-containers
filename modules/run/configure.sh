#!/bin/sh
# Configure module
set -e

SCRIPT_DIR=$(dirname $0)
ARTIFACTS_DIR=${SCRIPT_DIR}/artifacts

chown -R $USER:root $SCRIPT_DIR
chmod -R ug+rwX $SCRIPT_DIR
chmod ug+x ${ARTIFACTS_DIR}/opt/jboss/container/java/run/*

pushd ${ARTIFACTS_DIR}
cp -pr * /
popd

mkdir -p /deployments/data \
 && chmod -R "ug+rwX" /deployments/data \
 && chown -R $USER:root /deployments/data

# OPENJDK-100: turn off negative DNS caching
if [ -w ${JAVA_HOME}/jre/lib/security/java.security ]; then
    # JDK8 location
    javasecurity="${JAVA_HOME}/jre/lib/security/java.security"
elif [ -w ${JAVA_HOME}/lib/security/java.security ]; then
    # JDK8 JRE location
    javasecurity="${JAVA_HOME}/lib/security/java.security"
else
    # JDK11 location
    javasecurity="${JAVA_HOME}/conf/security/java.security"
fi
sed -i 's/\(networkaddress.cache.negative.ttl\)=[0-9]\+$/\1=0/' "$javasecurity"
