# TODO: these tests are builder-specific, since they invoke S2I. But they  don't
# need to be: they could start the container w/o a valid JAR and the Java CMD would
# still be echoed. Then it would be much faster and applicable to runtime images
# too.
@openjdk
@ubi8/openjdk-8
@ubi8/openjdk-11
@ubi8/openjdk-17
@ubi9/openjdk-8
@ubi9/openjdk-11
@ubi9/openjdk-17
@redhat-openjdk-18
Feature: Openshift OpenJDK GC tests

  Scenario: Check default GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then s2i build log should contain Using MAVEN_OPTS -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90

  Scenario: Check GC_MIN_HEAP_FREE_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_MIN_HEAP_FREE_RATIO           | 5      |
    Then s2i build log should contain Using MAVEN_OPTS -XX:+UseParallelGC -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90

  Scenario: Check GC_MAX_HEAP_FREE_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_MAX_HEAP_FREE_RATIO           | 50     |
    Then s2i build log should contain Using MAVEN_OPTS -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=50 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=50 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90

  Scenario: Check GC_TIME_RATIO GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_TIME_RATIO                    | 5      |
    Then s2i build log should contain Using MAVEN_OPTS -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=5 -XX:AdaptiveSizePolicyWeight=90
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=5 -XX:AdaptiveSizePolicyWeight=90

  Scenario: Check GC_ADAPTIVE_SIZE_POLICY_WEIGHT GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                         | value  |
       | GC_ADAPTIVE_SIZE_POLICY_WEIGHT   | 80     |
    Then s2i build log should contain Using MAVEN_OPTS -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=80
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=80

  Scenario: Check GC_MAX_METASPACE_SIZE GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                 | value  |
       | GC_MAX_METASPACE_SIZE    | 120    |
    Then s2i build log should contain Using MAVEN_OPTS -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=120m
    And container log should contain -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=120m

  Scenario: Check GC_CONTAINER_OPTIONS configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable             | value        |
       | GC_CONTAINER_OPTIONS | -XX:+UseG1GC |
    Then s2i build log should contain Using MAVEN_OPTS -XX:+UseG1GC
    And container log should contain -XX:+UseG1GC
    And container log should not contain -XX:+UseParallelGC

  Scenario: Check GC_METASPACE_SIZE GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                 | value  |
       | GC_METASPACE_SIZE    | 120    |
    Then s2i build log should contain -XX:MetaspaceSize=120m
    And container log should contain -XX:MetaspaceSize=120m
    And container log should not contain integer expression expected

  Scenario: Check GC_METASPACE_SIZE constrained by GC_MAX_METASPACE_SIZE GC configuration
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                 | value  |
       | GC_METASPACE_SIZE    | 120    |
       | GC_MAX_METASPACE_SIZE    | 90    |
    Then s2i build log should contain -XX:MaxMetaspaceSize=90m -XX:MetaspaceSize=90m
    And container log should contain -XX:MaxMetaspaceSize=90m -XX:MetaspaceSize=90m

