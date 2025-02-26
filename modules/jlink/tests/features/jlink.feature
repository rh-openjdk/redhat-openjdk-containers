@ubi9/openjdk-17
@openjdk-tech-preview/openjdk-21-jlink-rhel9
Feature: Openshift OpenJDK S2I tests (jlink specific)

  Scenario: tech preview warning is printed (OPENJDK-3038)
      Given failing s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target using master
       | variable            | value        |
       | S2I_ENABLE_JLINK    | true         |
      Then s2i build log should contain Jlink integration is a Tech Preview feature

Scenario: Ensure S2I_ENABLE_JLINK is not set to true
      Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from quarkus-quickstarts/getting-started-3.0.1.Final-nos2i
      Then container log should not contain S2I_ENABLE_JLINK=true
      And run bash -c "test ! -d /tmp/jre && echo PASS" in container and immediately check its output for PASS

Scenario: Check that /tmp/jre/bin/java and /tmp/jre/lib/modules exist post s2i build if jlink is enabled.
      Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from quarkus-quickstarts/getting-started-3.9.2-uberjar
       | variable            | value        |
       | S2I_ENABLE_JLINK    | true         |
      Then container log should contain S2I_ENABLE_JLINK=true
      and run bash -c "test -d /tmp/jre/bin/java && test -d /tmp/jre/lib/modules && echo PASS" in container and immediately check its output for PASS
