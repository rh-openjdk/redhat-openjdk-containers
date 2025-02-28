@ubi9/openjdk-11
@ubi9/openjdk-17
@ubi9/openjdk-21
Feature: Openshift OpenJDK S2I tests

  # test incremental builds
  Scenario: Check incremental builds cache .m2
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from undertow-servlet
        | variable    | value               |
        | JAVA_ARGS   | Hello from CTF test |
    Then container log should contain /deployments/undertow-servlet.jar Hello from CTF test
     And s2i build log should contain Downloading from central:
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from undertow-servlet with env and incremental
        | variable    | value               |
        | JAVA_ARGS   | Hello from CTF test |
    Then container log should contain /deployments/undertow-servlet.jar Hello from CTF test
     And s2i build log should not contain Downloading from central:
