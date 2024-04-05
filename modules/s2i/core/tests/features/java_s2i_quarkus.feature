# builder only
@ubi9/openjdk-11
@ubi9/openjdk-17
@ubi9/openjdk-21
Feature: Openshift OpenJDK S2I tests (Quarkus-based)

  Scenario: Ensure Quarkus CDS doesn't fail due to timestamp mismatch (OPENDJK-1673)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from getting-started
    Then container log should not contain A jar file is not the one used while building the shared archive file

  Scenario: quarkus fast-jar layout works out-of-the-box (OPENJDK-631)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from quarkus-quickstarts/getting-started-3.0.1.Final-nos2i
    Then container log should contain INFO quarkus fast-jar package type detected
    And  container log should contain -jar /deployments/quarkus-app/quarkus-run.jar
    And  container log should contain (main) getting-started 1.0.0-SNAPSHOT on JVM (powered by Quarkus
    # these might occur if the wrong JAR is chosen as the main one
    And  container log should not contain -jar /deployments/getting-started-1.0.0-SNAPSHOT.jar
    And  container log should not contain no main manifest attribute

  Scenario: quarkus uber-jar layout works out-of-the-box (OPENJDK-631)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from quarkus-quickstarts/getting-started-3.0.1.Final-nos2i with env
       | variable             | value    |
       | QUARKUS_PACKAGE_TYPE | uber-jar |
    Then container log should not contain INFO quarkus fast-jar package type detected
    And  container log should not contain -jar /deployments/quarkus-app/quarkus-run.jar
    And  container log should contain -jar /deployments/getting-started-1.0.0-SNAPSHOT-runner.jar
    And  container log should contain (main) getting-started 1.0.0-SNAPSHOT on JVM (powered by Quarkus
