#multi-stage build for jlinked application JAR and JRE

#Stage-1:build application JAR and libraries
#steps to build the application JAR and jlinked JRE
#for time being using the image built by Jon
FROM quay.io/jdowland/jlink:quarkus-getting-started AS ubi9-jlinked-image
USER 0
RUN mkdir -p /mnt/jrootfs
RUN microdnf install dnf -y
RUN dnf install --installroot /mnt/jrootfs grep gawk --releasever 9 --setopt install_weak_deps=false --nodocs -y;dnf clean all
RUN rm -rf /mnt/jrootfs/var/cache/*
RUN rm -rf /mnt/jrootfs/var/lib/rpm
USER 185

#Stage-2:copy application JAR and jlinked JRE to runtime image
FROM registry.access.redhat.com/ubi9/ubi-micro AS lean-runtime

COPY --from=ubi9-jlinked-image /mnt/jrootfs/ /
COPY --from=ubi9-jlinked-image /deployments /deployments
COPY --from=ubi9-jlinked-image /tmp/jre /usr/lib/jvm/java
COPY --from=ubi9-jlinked-image /opt/jboss/container/java/run/run-java.sh /opt/jboss/container/java/run/run-java.sh
COPY --from=ubi9-jlinked-image /opt/jboss/container/util/logging/logging.sh /opt/jboss/container/util/logging/logging.sh
COPY --from=ubi9-jlinked-image /opt/jboss/container/java/run/run-env.sh /opt/jboss/container/java/run/run-env.sh 
RUN ls -LR /opt/jboss/container/

ENV JAVA_HOME="/usr/lib/jvm/java"
RUN echo $JAVA_HOME

ENV PATH="$JAVA_HOME/bin/:$PATH"
RUN echo $PATH

ENV JBOSS_CONTAINER_UTIL_LOGGING_MODULE=/opt/jboss/container/util/logging
ENV JBOSS_CONTAINER_JAVA_RUN_MODULE=/opt/jboss/container/java/run

CMD /opt/jboss/container/java/run/run-java.sh

