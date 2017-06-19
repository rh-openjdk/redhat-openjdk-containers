Feature: tests for all openshift images

  Scenario: Check that labels are correctly set
    Given image is built
    Then the image should contain label release
    And the image should contain label version
    And the image should contain label name
    And the image should contain label architecture with value x86_64
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
