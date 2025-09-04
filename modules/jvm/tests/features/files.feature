Feature: test file properties for JVM module

  @ubi10
  Scenario: Ensure image scripts are executable (OPENJDK-3935)
    When container is started with args
    | arg     | value                                                        |
    | command | find /opt/jboss/container/java/ -type f -printf "%h/%f %M\n" |
    Then available container log should contain /opt/jboss/container/java/jvm/debug-options -rwxr-xr-x
    And  available container log should contain /opt/jboss/container/java/jvm/java-default-options -rwxr-xr-x
