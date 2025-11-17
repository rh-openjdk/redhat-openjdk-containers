Feature: Tests around compact object headers

  @ubi10/openjdk-25
  @ubi10/openjdk-25-runtime
  Scenario: UseCompactObjectHeaders is on by default
    When container is ready
    Then available container log should contain -XX:+UseCompactObjectHeaders

  @ubi10/openjdk-25
  @ubi10/openjdk-25-runtime
  Scenario: UseCompactObjectHeaders can be disabled
    Given container is started with env
     | variable                    | value |
     | JAVA_COMPACT_OBJECT_HEADERS | false |
    Then available container log should not contain -XX:+UseCompactObjectHeaders
