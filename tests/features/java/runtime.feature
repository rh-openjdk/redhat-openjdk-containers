@openjdk
@centos/openjdk-8-centos7 @centos/openjdk-11-centos7
Feature: Openshift OpenJDK Runtime tests

  Scenario: Ensure JVM_ARGS is no longer present in the run script
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
    Then file /usr/local/s2i/run should not contain JVM_ARGS

  Scenario: Ensure JAVA_ARGS are passed through to the running java application
    Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable    | value               |
       | JAVA_ARGS   | Hello from CTF test |
    Then container log should contain /deployments/undertow-servlet.jar Hello from CTF test
