@ubi9
Feature: Openshift OpenJDK GC tests

  Scenario: Check default GC configuration
    Given container is started as uid 1000
    Then container log should contain -XX:+UseParallelGC
    And  container log should contain -XX:MinHeapFreeRatio=10
    And  container log should contain -XX:MaxHeapFreeRatio=20
    And  container log should contain -XX:GCTimeRatio=4

  Scenario: Check GC_MIN_HEAP_FREE_RATIO GC configuration
    Given container is started with env
       | variable                         | value  |
       | GC_MIN_HEAP_FREE_RATIO           | 5      |
    Then container log should contain -XX:MinHeapFreeRatio=5

  Scenario: Check GC_MAX_HEAP_FREE_RATIO GC configuration
    Given container is started with env
       | variable                         | value  |
       | GC_MAX_HEAP_FREE_RATIO           | 50     |
    Then container log should contain -XX:MaxHeapFreeRatio=50

  Scenario: Check GC_TIME_RATIO GC configuration
    Given container is started with env
       | variable                         | value  |
       | GC_TIME_RATIO                    | 5      |
    Then container log should contain -XX:GCTimeRatio=5

  Scenario: Check GC_ADAPTIVE_SIZE_POLICY_WEIGHT GC configuration
    Given container is started with env
       | variable                         | value  |
       | GC_ADAPTIVE_SIZE_POLICY_WEIGHT   | 80     |
    Then container log should contain -XX:AdaptiveSizePolicyWeight=80

  Scenario: Check GC_MAX_METASPACE_SIZE GC configuration
    Given container is started with env
       | variable                 | value  |
       | GC_MAX_METASPACE_SIZE    | 120    |
    Then container log should contain -XX:MaxMetaspaceSize=120m

  Scenario: Check GC_CONTAINER_OPTIONS configuration
    Given container is started with env
       | variable             | value        |
       | GC_CONTAINER_OPTIONS | -XX:+UseG1GC |
    Then container log should contain -XX:+UseG1GC
    And container log should not contain -XX:+UseParallelGC

  Scenario: Check GC_METASPACE_SIZE GC configuration
    Given container is started with env
       | variable             | value  |
       | GC_METASPACE_SIZE    | 120    |
    Then container log should contain -XX:MetaspaceSize=120m
    And container log should not contain integer expression expected

  Scenario: Check GC_METASPACE_SIZE constrained by GC_MAX_METASPACE_SIZE GC configuration
    Given container is started with env
       | variable                 | value |
       | GC_METASPACE_SIZE        | 120   |
       | GC_MAX_METASPACE_SIZE    | 90    |
    Then container log should contain -XX:MaxMetaspaceSize=90m
    And  container log should contain -XX:MetaspaceSize=90m
