# TODO: Is there any reason this is S2I specific? Should we rework this so
# we can test the runtime images?
@openjdk
@ubi8/openjdk-8
@ubi8/openjdk-11
@ubi8/openjdk-17
@redhat-openjdk-18
Feature: Openshift S2I tests
  Scenario: Check networkaddress.cache.negative.ttl has been set correctly
    Given s2i build https://github.com/jboss-openshift/openshift-examples/ from binary-cli-security-property
    Then s2i build log should contain networkaddress.cache.negative.ttl=0
