@ubi9/openjdk-11
@ubi9/openjdk-17
@ubi9/openjdk-21
Feature: Openshift OpenJDK Runtime tests (OPENJDK-474)

  Scenario: Ensure JAVA_ARGS is passed through, diagnostic options work correctly, JVM_ARGS not present in run script, OPENJDK-474 JAVA_ARGS not repeated
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from undertow-servlet
       | variable         | value  |
       | JAVA_ARGS        | unique |
       | JAVA_DIAGNOSTICS | true   |
    Then container log should contain /deployments/undertow-servlet.jar unique
     And container log should contain -XX:NativeMemoryTracking=summary
     And file /usr/local/s2i/run should not contain JVM_ARGS
     And container log should not contain unique unique
