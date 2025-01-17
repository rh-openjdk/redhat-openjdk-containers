Feature: OPENJDK-559 JVM Memory tests

  @openjdk-els
  Scenario: Check default JVM max heap configuration
    Given container is started as uid 1000
    Then container log should contain -XX:MaxRAMPercentage=80.0
    And  container log should not contain -Xmx

  @openjdk-els
  Scenario: Check configured JVM max heap configuration and ensure JAVA_MAX_MEM_RATIO accepts floats but only takes whole number part
    Given container is started with env
    | variable           | value  |
    | JAVA_MAX_MEM_RATIO | 90.4   |
    Then container log should contain -XX:MaxRAMPercentage=90.0

  @openjdk-els
  Scenario: Ensure JAVA_MAX_MEM_RATIO accepts Integers
    Given container is started with env
    | variable           | value  |
    | JAVA_MAX_MEM_RATIO | 90     |
    Then container log should contain -XX:MaxRAMPercentage=90.0

  @openjdk-els
  Scenario: Ensure JAVA_INITIAL_MEM_RATIO accepts Integers
    Given container is started with env
    | variable               | value  |
    | JAVA_INITIAL_MEM_RATIO | 10     |
    Then container log should contain -XX:InitialRAMPercentage=10.0

  @openjdk-els
  Scenario: Ensure JAVA_MAX_MEM_RATIO=0 disables parameter
    Given container is started with env
    | variable           | value  |
    | JAVA_MAX_MEM_RATIO | 0     |
    Then container log should not contain -XX:MaxRAMPercentage

  @openjdk-els
  Scenario: Check default JVM initial heap configuration is unspecified
    Given container is started as uid 1000
    Then container log should not contain -XX:InitialRAMPercentage
    And  container log should not contain -Xms

  @openjdk-els
  Scenario: Check configured JVM max heap configuration and ensure JAVA_INITIAL_MEM_RATIO accepts floats but only takes whole number part
    Given container is started with env
    | variable               | value  |
    | JAVA_INITIAL_MEM_RATIO | 25.2   |
    Then container log should contain -XX:InitialRAMPercentage=25.0

  @openjdk-els
  Scenario: check JAVA_MAX_INITIAL_MEM overrides JAVA_INITIAL_MEM_RATIO
    Given container is started with env
    | variable               | value  |
    | JAVA_INITIAL_MEM_RATIO | 25.0   |
    | JAVA_MAX_INITIAL_MEM   | 4096m  |
    Then container log should contain -Xms4096m
    And  container log should not contain -XX:InitialRAMPercentage=25.0

  # Not the runtime images
  @ubi8/openjdk-8
  @openjdk-els/openjdk-11-rhel8
  @ubi8/openjdk-17
  @ubi8/openjdk-21
  Scenario: Ensure Maven doesn't use MaxRAMPercentage=80
    Given s2i build https://github.com/rh-openjdk/openjdk-container-test-applications.git from spring-boot-sample-simple
    Then s2i build log should match regex INFO Using MAVEN_OPTS.*-XX:MaxRAMPercentage=25.0$
