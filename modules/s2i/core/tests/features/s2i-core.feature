@ubi10/openjdk-21
@ubi10/openjdk-25
@openjdk-tech-preview/openjdk-21-jlink-rhel9
Feature: Openshift S2I tests
  # OPENJDK-84 - /tmp/src should not be present after build
  Scenario: run an s2i build and check that /tmp/src has been removed afterwards
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from spring-boot-sample-simple
    Then run stat /tmp/src in container and immediately check its output does not contain File:

    # OPENJDK-2850 - ensure binary-only s2i doesn't try to change timestamps of
    # S2I_TARGET_DEPLOYMENTS_DIR. Use /var/tmp as a directory where attempting to
    # will fail. This simulates the s2i process running as a random UID, which can't
    # change timestamps on the default directory, /deployments.
  Scenario: Ensure binary-only build doesn't fail trying to set timestamp of S2I_TARGET_DEPLOYMENTS_DIR (OPENJDK-2850)
      Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from OPENJDK-2408-bin-custom-s2i-assemble with env
       | variable                   | value |
       | S2I_TARGET_DEPLOYMENTS_DIR | /var/tmp  |
     Then s2i build log should not contain rsync: [generator] failed to set permissions on "/var/tmp/.": Operation not permitted
     And  s2i build log should contain appsrc-provided s2i assemble script executed
     And  run stat /var/tmp/spring-boot-sample-simple-1.5.0.BUILD-SNAPSHOT.jar in container and check its output for Access:

  # as above, for OPENJDK-3975: handling configuration
  Scenario: Ensure copying custom configuration doesn't fail trying to chmod destination directory (OPENJDK-3975)
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from OPENJDK-2408-bin-custom-s2i-assemble with env
       | variable                     | value    |
       | S2I_TARGET_CONFIGURATION_DIR | /var/tmp |
    Then s2i build log should not contain rsync: [generator] failed to set permissions on "/var/tmp/.": Operation not permitted
    And  s2i build log should contain appsrc-provided s2i assemble script executed
    And  run stat /var/tmp/example.ini in container and check its output for Access:

  # as above, for OPENJDK-3975: handling data
  Scenario: Ensure copying custom data doesn't fail trying to chmod destination directory (OPENJDK-3975)
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from OPENJDK-2408-bin-custom-s2i-assemble with env
       | variable                     | value    |
       | S2I_TARGET_DATA_DIR          | /var/tmp |
    Then s2i build log should not contain rsync: [generator] failed to set permissions on "/var/tmp/.": Operation not permitted
    And  s2i build log should contain appsrc-provided s2i assemble script executed
    And  run stat /var/tmp/sample.txt in container and check its output for Access:
