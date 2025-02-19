Feature: Miscellaneous OpenJDK-related unit tests

  @ubi9/openjdk-11
  @ubi9/openjdk-11-runtime
  Scenario: Check that only OpenJDK 11 is installed
    When container is started with args
    | arg     | value   |
    | command | rpm -qa |
    Then available container log should not contain java-1.8.0
    Then available container log should not contain java-17
    Then available container log should not contain java-21

  @ubi9/openjdk-17
  @ubi9/openjdk-17-runtime
  Scenario: Check that only OpenJDK 17 is installed
    When container is started with args
    | arg     | value   |
    | command | rpm -qa |
    Then available container log should not contain java-1.8.0
    Then available container log should not contain java-11
    Then available container log should not contain java-21

  @ubi9/openjdk-21
  @ubi9/openjdk-21-runtime
  Scenario: Check that only OpenJDK 21 is installed
    When container is started with args
    | arg     | value   |
    | command | rpm -qa |
    Then available container log should not contain java-1.8.0
    Then available container log should not contain java-11
    Then available container log should not contain java-17

  @ubi9
  Scenario: Ensure JAVA_HOME is defined and contains Java
    When container is started with args
    | arg     | value                                  |
    | command | bash -c "$JAVA_HOME/bin/java -version" |
    Then available container log should contain OpenJDK Runtime Environment

  @ubi9
  Scenario: Check that certain non-UBI packages are not installed
    When container is started with args
    | arg     | value   |
    | command | rpm -qa |
    Then available container log should not contain grub
    Then available container log should not contain os-prober
    Then available container log should not contain rpm-plugin-systemd-inhibit

  @ubi9/openjdk-11
  @ubi9/openjdk-11-runtime
  Scenario: Check that directories from other JDKs are not present (JDK11)
    When container is started with args
    | arg     | value   |
    | command | ls -1 /usr/lib/jvm |
    Then available container log should not contain java-1.8.0
    Then available container log should not contain java-17
    Then available container log should not contain java-21

  @ubi9/openjdk-17
  @ubi9/openjdk-17-runtime
  Scenario: Check that directories from other JDKs are not present (JDK17)
    When container is started with args
    | arg     | value   |
    | command | ls -1 /usr/lib/jvm |
    Then available container log should not contain java-1.8.0
    Then available container log should not contain java-11
    Then available container log should not contain java-21

  @ubi9/openjdk-21
  @ubi9/openjdk-21-runtime
  Scenario: Check that directories from other JDKs are not present (JDK21)
    When container is started with args
    | arg     | value   |
    | command | ls -1 /usr/lib/jvm |
    Then available container log should not contain java-1.8.0
    Then available container log should not contain java-11
    Then available container log should not contain java-17

  @ubi9
  Scenario: Ensure LANG is defined and contains UTF-8
    When container is started with args
    | arg     | value                                  |
    | command | bash -c "$JAVA_HOME/bin/java -XshowSettings:properties -version" |
    Then available container log should contain file.encoding = UTF-8

  @ubi9
  Scenario: Ensure tar is installed (OPENJDK-1165)
    When container is started with args
    | arg     | value |
    | command | tar   |
    Then available container log should not contain command not found

  @ubi9
  Scenario: Ensure tzdata RPM is properly installed (OPENJDK-2519)
    When container is started with args
    | arg     | value         |
    | command | rpm -V tzdata |
    Then available container log should not contain missing
