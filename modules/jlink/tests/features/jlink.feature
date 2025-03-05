@openjdk-tech-preview/openjdk-21-jlink-rhel9
Feature: Openshift OpenJDK S2I tests (jlink specific)

  Scenario: tech preview warning is printed (OPENJDK-3038)
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications from spring-boot-sample-simple/target using master
       | variable            | value        |
       | S2I_ENABLE_JLINK    | true         |
      Then s2i build log should contain Jlink integration is a Tech Preview feature

Scenario: Ensure S2I_ENABLE_JLINK is not set to true
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications from spring-boot-sample-simple/target using master
     Then s2i build log should not contain Jlink integration is a Tech Preview feature
      And file /tmp/jre should not exist

Scenario: Check that /tmp/jre/bin/java and /tmp/jre/lib/modules exist post s2i build if jlink is enabled.
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications from quarkus-quickstarts/getting-started-3.9.2-uberjar
       | variable            | value        |
       | S2I_ENABLE_JLINK    | true         |
      Then file /tmp/jre/bin/java should exist and be a file
       And file /tmp/jre/lib/modules should exist and be a file

Scenario: Check that /tmp/jlink is deleted when S2I_DELETE_SOURCE is set
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications from quarkus-quickstarts/getting-started-3.9.2-uberjar
       | variable            | value        |
       | S2I_ENABLE_JLINK    | true         |
       | S2I_DELETE_SOURCE   | true         |
      Then s2i build log should contain Cleaning up temporary file directory /tmp/jlink
       And file /tmp/jlink should not exist