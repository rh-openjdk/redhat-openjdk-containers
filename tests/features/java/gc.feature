Feature: Openshift OpenJDK GC tests

  Scenario: Check default GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then s2i build log should contain Setting MAVEN_OPTS to -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m

  Scenario: Check GC_MIN_HEAP_FREE_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_MIN_HEAP_FREE_RATIO           | 30     |
    Then s2i build log should contain Setting MAVEN_OPTS to -XX:+UseParallelGC -XX:MinHeapFreeRatio=30 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=30 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m

  Scenario: Check GC_MAX_HEAP_FREE_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_MAX_HEAP_FREE_RATIO           | 50     |
    Then s2i build log should contain Setting MAVEN_OPTS to -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=50 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=50 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m

  Scenario: Check GC_TIME_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_TIME_RATIO                    | 5      |
    Then s2i build log should contain Setting MAVEN_OPTS to -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=5 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=5 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m

  Scenario: Check GC_ADAPTIVE_SIZE_POLICY_WEIGHT GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_ADAPTIVE_SIZE_POLICY_WEIGHT   | 80     |
    Then s2i build log should contain Setting MAVEN_OPTS to -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=80 -XX:MaxMetaspaceSize=100m
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=80 -XX:MaxMetaspaceSize=100m

  Scenario: Check GC_MAX_METASPACE_SIZE GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                 | value  |
       | GC_MAX_METASPACE_SIZE    | 120    |
    Then s2i build log should contain Setting MAVEN_OPTS to -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=120m
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=120m
