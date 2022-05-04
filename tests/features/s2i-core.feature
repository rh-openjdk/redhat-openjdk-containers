@openjdk
@ubi8/openjdk-8
@ubi8/openjdk-11
@ubi8/openjdk-17
@ubi9/openjdk-8
@ubi9/openjdk-11
@ubi9/openjdk-17
@redhat-openjdk-18
Feature: Openshift S2I tests
  # OPENJDK-84 - /tmp/src should not be present after build
  Scenario: run an s2i build and check that /tmp/src has been removed afterwards
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
    Then run stat /tmp/src in container and immediately check its output does not contain File:
