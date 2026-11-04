@ubi10
Feature: Tests for /licenses directory and licenses

  Scenario: Check Java base LICENSE file exists under /licenses (OPENJDK-4572)
    When container is started with args
    | arg     | value                                    |
    | command | stat /licenses/openjdk/java.base/LICENSE |
    Then available container log should contain regular file
