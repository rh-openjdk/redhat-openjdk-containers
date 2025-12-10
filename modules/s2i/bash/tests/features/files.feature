# builder-only test
@ubi9/openjdk-17
@ubi9/openjdk-21
@ubi9/openjdk-25
Feature: OpenJDK S2I bash module tests

  Scenario: Ensure image scripts are executable (OPENJDK-3935)
    When container is started with args
    | arg     | value                                                        |
    | command | find /usr/local/s2i/ -type f -printf "%h/%f %M\n" |
    Then available container log should contain run -rwxr-xr-x
    And available container log should contain assemble -rwxr-xr-x
    And available container log should contain usage -rwxr-xr-x
