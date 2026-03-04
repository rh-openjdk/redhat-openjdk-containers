@ubi10
Feature: Tests for /licenses directory and licenses

  Scenario: Check that builder labels are correctly set
    Given image is built
    Then file /licenses should exist and be a directory
    And  file /licenses/legal should exist

  Scenario: Check that /licenses directory exists (OPENJDK-4572)
    When container is started with args
    | arg     | value          |
    | command | stat /licenses |
    Then available container log should contain IO Block: 4096   directory
