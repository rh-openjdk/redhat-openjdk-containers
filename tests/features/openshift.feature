@openjdk
@ubi8/openjdk-8
@ubi8/openjdk-11
@ubi8/openjdk-17
@ubi9/openjdk-8
@ubi9/openjdk-11
@ubi9/openjdk-17
@redhat-openjdk-18
Feature: Tests for all openshift images

  @ubi8
  @ubi9
  Scenario: Check that product labels are correctly set
    # We don't set 'release' or 'architecture' on CI builds, but it's set on OSBS builds
    # Since we base on an image which has it already set, it's kind of meaningless
    # to test it, but it's left here for usage with OSBS-built images.
    # These are also not set on community images, so we cannot test both flavors with the same set.
    Given image is built
    Then the image should contain label release
    And the image should contain label architecture with value x86_64

  Scenario: Check that common labels are correctly set
    Given image is built
    Then the image should contain label version
    And the image should contain label name
    And the image should contain label io.openshift.s2i.scripts-url with value image:///usr/local/s2i
