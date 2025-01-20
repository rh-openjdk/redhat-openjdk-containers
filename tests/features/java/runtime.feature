@ubi9/openjdk-11
@ubi9/openjdk-17
@openjdk-tech-preview/openjdk-21-jlink-rhel9
Feature: Openshift OpenJDK Runtime tests

  Scenario: Ensure JAVA_ARGS is passed through, diagnostic options work correctly, JVM_ARGS not present in run script, OPENJDK-474 JAVA_ARGS not repeated
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from undertow-servlet
       | variable         | value  |
       | JAVA_ARGS        | unique |
       | JAVA_DIAGNOSTICS | true   |
    Then container log should contain /deployments/undertow-servlet.jar unique
     And container log should contain -XX:NativeMemoryTracking=summary
     And file /usr/local/s2i/run should not contain JVM_ARGS
     And container log should not contain unique unique

  @ubi9
  Scenario: Check JAVA_OPTS overrides defaults
    Given container is started with env
    | variable  | value          |
    | JAVA_OPTS | --show-version |
    Then container log should not contain -XX:MaxRAMPercentage

  @ubi9
  Scenario: Check empty JAVA_OPTS overrides defaults
    Given container is started with env
    | variable  | value          |
    | JAVA_OPTS |                |
    Then container log should not contain -XX:MaxRAMPercentage

  @ubi9
  Scenario: Check JAVA_OPTS overrides JAVA_OPTS_APPEND
    Given container is started with env
    | variable         | value          |
    | JAVA_OPTS        | -verbose:gc    |
    | JAVA_OPTS_APPEND | -Xint          |
    Then container log should contain -verbose:gc
     And container log should not contain -Xint

  @ubi9
  Scenario: Check JAVA_APP_NAME can contain spaces (OPENJDK-1551)
    Given container is started with env
    | variable         | value   |
    | JAVA_APP_NAME    | foo bar |
  Then container log should not contain exec: bar': not found

  @ubi9
  Scenario: Check default JAVA_APP_DIR (OPENJDK-2034)
  When container is ready
  Then available container log should contain INFO running in /deployments

  @ubi9
  Scenario: Check custom JAVA_APP_DIR (OPENJDK-2034)
    Given container is started with env
    | variable     | value         |
    | JAVA_APP_DIR | /home/default |
  Then available container log should contain INFO running in /home/default

  @ubi9
  Scenario: Check relative path JAVA_APP_DIR (OPENJDK-2034)
    Given container is started with env
    | variable     | value  |
    | JAVA_APP_DIR | .      |
  Then available container log should contain INFO running in /home/default

  @ubi9
  Scenario: Check non-existent path JAVA_APP_DIR (OPENJDK-2034)
    Given container is started with env
    | variable     | value  |
    | JAVA_APP_DIR | /nope  |
  Then available container log should contain ERROR No directory /nope found for auto detection

  # Builder images only
  Scenario: Ensure JAVA_APP_DIR and S2I work together (OPENJDK-2034)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from undertow-servlet
       | variable                   | value         |
       | JAVA_APP_DIR               | /home/default |
       | S2I_TARGET_DEPLOYMENTS_DIR | /home/default |
    Then container log should contain /home/default/undertow-servlet.jar
