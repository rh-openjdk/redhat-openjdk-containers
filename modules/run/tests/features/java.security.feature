@ubi10/openjdk-21
@ubi10/openjdk-25
@openjdk-tech-preview/openjdk-21-jlink-rhel9
Feature: Openshift S2I tests
  Scenario: Check networkaddress.cache.negative.ttl has been set correctly
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from binary-cli-security-property
    Then s2i build log should contain networkaddress.cache.negative.ttl=0
