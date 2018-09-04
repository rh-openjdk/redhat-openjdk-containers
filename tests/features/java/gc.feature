@redhat-openjdk-18/openjdk18-openshift
Feature: Openshift OpenJDK GC tests

  Scenario: Check default GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then s2i build log should match regex Setting MAVEN_OPTS to.*-XX:\+UseParallelOldGC
    And  s2i build log should match regex Setting MAVEN_OPTS to.*-XX:\+UnlockExperimentalVMOptions
    And  s2i build log should match regex Setting MAVEN_OPTS to.*-XX:\+UseCGroupMemoryLimitForHeap
    And  s2i build log should match regex Setting MAVEN_OPTS to.*-XX:MinHeapFreeRatio=10
    And  s2i build log should match regex Setting MAVEN_OPTS to.*-XX:MaxHeapFreeRatio=20
    And  s2i build log should match regex Setting MAVEN_OPTS to.*-XX:GCTimeRatio=4
    And  s2i build log should match regex Setting MAVEN_OPTS to.*-XX:AdaptiveSizePolicyWeight=90
    And  s2i build log should match regex Setting MAVEN_OPTS to.*-XX:MaxMetaspaceSize=100m
    And  s2i build log should match regex Setting MAVEN_OPTS to.*-XX:\+ExitOnOutOfMemoryError
    And  container log should contain -XX:+UseParallelOldGC
    And  container log should contain -XX:+UnlockExperimentalVMOptions
    And  container log should contain -XX:+UseCGroupMemoryLimitForHeap
    And  container log should contain -XX:MinHeapFreeRatio=10
    And  container log should contain -XX:MaxHeapFreeRatio=20
    And  container log should contain -XX:GCTimeRatio=4
    And  container log should contain -XX:AdaptiveSizePolicyWeight=90
    And  container log should contain -XX:MaxMetaspaceSize=100m
    And  container log should contain -XX:+ExitOnOutOfMemoryError

  Scenario: Check GC_MIN_HEAP_FREE_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_MIN_HEAP_FREE_RATIO           | 5      |
    Then s2i build log should match regex Setting MAVEN_OPTS to.*-XX:MinHeapFreeRatio=5
    And  container log should contain -XX:MinHeapFreeRatio=5

  Scenario: Check GC_MAX_HEAP_FREE_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_MAX_HEAP_FREE_RATIO           | 50     |
    Then s2i build log should match regex Setting MAVEN_OPTS to.*-XX:MaxHeapFreeRatio=50
    And  container log should contain -XX:MaxHeapFreeRatio=50

  Scenario: Check GC_TIME_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_TIME_RATIO                    | 5      |
    Then s2i build log should match regex Setting MAVEN_OPTS to.*-XX:GCTimeRatio=5
    And  container log should contain -XX:GCTimeRatio=5

  Scenario: Check GC_ADAPTIVE_SIZE_POLICY_WEIGHT GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_ADAPTIVE_SIZE_POLICY_WEIGHT   | 80     |
    Then s2i build log should match regex Setting MAVEN_OPTS to.*-XX:AdaptiveSizePolicyWeight=80
    And  container log should contain -XX:AdaptiveSizePolicyWeight=80

  Scenario: Check GC_MAX_METASPACE_SIZE GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                 | value  |
       | GC_MAX_METASPACE_SIZE    | 120    |
    Then s2i build log should match regex Setting MAVEN_OPTS to.*-XX:MaxMetaspaceSize=120m
    And  container log should contain -XX:MaxMetaspaceSize=120m
