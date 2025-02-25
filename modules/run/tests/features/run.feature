@ubi9
Feature: OpenJDK run script tests
  Scenario: Ensure command-line options containing 'password' are masked in logs
    Given container is started with env
      | variable         | value                                              |
      | JAVA_OPTS_APPEND | -Djavax.net.ssl.trustStorePassword=sensitiveString |
    Then container log should not contain sensitiveString

