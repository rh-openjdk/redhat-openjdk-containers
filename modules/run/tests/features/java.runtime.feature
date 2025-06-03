@ubi9/openjdk-11
@ubi9/openjdk-17
@ubi9/openjdk-21
@ubi9/openjdk-25
Feature: Openshift OpenJDK Runtime tests (OPENJDK-474, OPENJDK-2805)

  Scenario: Ensure JAVA_ARGS is passed through, diagnostic options work correctly, JVM_ARGS not present in run script, OPENJDK-474 JAVA_ARGS not repeated
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from undertow-servlet
       | variable         | value  |
       | JAVA_ARGS        | unique |
       | JAVA_DIAGNOSTICS | true   |
    Then container log should contain /deployments/undertow-servlet.jar unique
     And container log should contain -XX:NativeMemoryTracking=summary
     And file /usr/local/s2i/run should exist
     And file /usr/local/s2i/run should not contain JVM_ARGS
     And file /usr/libexec/s2i/run should exist
     And file /usr/libexec/s2i/run should not contain JVM_ARGS
     And container log should not contain unique unique

  @ubi9
  # alternative to one of previous steps, for runtime images
  Scenario: OPENJDK-2968 Ensure JAVA_ARGS is passed to the running Java application
    Given container is started with env
       | variable    | value                 |
       | JAVA_ARGS   | Hello from Cekit test |
    Then container log should match regex ^INFO exec -a "java" java.*Hello from Cekit test$
