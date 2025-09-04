Feature: test file properties for Maven S2I module

  # builder-only test
  @ubi10/openjdk-21
  Scenario: Ensure save-artifacts script is executable (OPENJDK-3935)
    When container is started with args
    | arg     | value                                         |
    | command | find /usr/local/s2i -type f -printf "%f %M\n" |
    Then available container log should contain save-artifacts -rwxr-xr-x
