@ubi9
Feature: OpenJDK run script tests
  Scenario: Ensure command-line options containing 'password' are masked in logs
    Given container is started with env
      | variable         | value                                              |
      | JAVA_OPTS_APPEND | -Djavax.net.ssl.trustStorePassword=sensitiveString |
    Then container log should not contain sensitiveString

  Scenario: Ensure image scripts are executable (OPENJDK-3935)
    When container is started with args
    | arg     | value                                                        |
    | command | find /opt/jboss/container/java/ -type f -printf "%h/%f %M\n" |
    Then available container log should contain /opt/jboss/container/java/run/run-java.sh -rwxr-xr-x
