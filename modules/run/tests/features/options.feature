@ubi8
Feature: OpenJDK run script option handling

  Scenario: JAVA_OPTIONS sets JAVA_OPTS and overrides defaults (OPENJDK-2009)
    Given container is started with env
    | variable     | value          |
    | JAVA_OPTIONS | --show-version |
    Then container log should not contain -XX:MaxRAMPercentage
    And  container log should match regex ^INFO exec.*java --show-version
