Feature: Tests for all openshift images

  @ubi9
  Scenario: Check that common labels are correctly set
    Given image is built
    # UBI base image versions are the RHEL version, e.g. "9.2", whereas all of
    # our image versions (so far) have been 1.x
    Then the image should contain label version containing value 1.
    And the image should contain label name containing value openjdk

  # builder-only test
  @ubi9/openjdk-11
  @ubi9/openjdk-17
  @ubi9/openjdk-21
  @ubi9/openjdk-25
  Scenario: Check that builder labels are correctly set
    Given image is built
    Then the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i

  @ubi9
  Scenario: Check installed scripts are executable by all users (OPENJDK-3655)
    When container is started with args
    | arg     | value                                                             |
    | command | find /opt/jboss/container -type f -perm -g+x ( ! -perm -o+x ) -ls |
    Then available container log should not contain /opt/jboss/container
