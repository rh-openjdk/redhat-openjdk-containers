@ubi9/openjdk-17
@openjdk-tech-preview/openjdk-21-jlink-rhel9
Feature: Openshift OpenJDK S2I tests (jlink specific)
Scenario: Ensure jlinked builder is used to build the containerized application image
      Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from quarkus-quickstarts/getting-started-3.0.1.Final-nos2i
       | variable            | value        |
       | S2I_ENABLE_JLINK    | true         |
       | QUARKUS_PACKAGE_TYPE| uber-jar     |
      Then run ls /tmp/jre in container and check its output for bin

Scenario: Ensure S2I_ENABLE_JLINK is not set to true
      Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from quarkus-quickstarts/getting-started-3.0.1.Final-nos2i
      Then container log should not contain S2I_ENABLE_JLINK=true
      And run bash -c "test ! -d /tmp/jre && echo PASS" in container and immediately check its output for PASS
