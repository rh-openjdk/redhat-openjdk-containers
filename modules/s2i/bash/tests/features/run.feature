@ubi8/openjdk-8
@ubi8/openjdk-11
@ubi8/openjdk-17
@ubi8/openjdk-21
Feature: S2I run script tests
 
  Scenario: OPENJDK-2968 application run script is invoked instead of image run script
      Given s2i build https://github.com/jmtd/openjdk-test-applications from OPENJDK-2968-bin-custom-run with env using OPENJDK-2968-custom-run
       | variable     | value      |
       | JAVA_OPTIONS | deprecated |
       | JAVA_ARGS    | percolated |
      Then container log should not contain Starting the Java application using /opt/jboss/container/java/run/run-java.sh
      And  container log should contain hello world
      And  container log should contain JAVA_OPTS=deprecated
      And  container log should contain args=percolated
