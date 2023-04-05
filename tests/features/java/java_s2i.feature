@ubi9/openjdk-11
@ubi9/openjdk-17
Feature: Openshift OpenJDK S2I tests
# NOTE: these tests should be usable with the other images once we have refactored the JDK scripts.
# These builds do not actually run maven. This is important, because the proxy
# options supplied do not specify a valid HTTP proxy.

  # handles mirror/repository configuration; proxy configuration
  Scenario: run the s2i and check the maven mirror and proxy have been initialised in the default settings.xml, uses http_proxy
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | MAVEN_MIRROR_URL   | http://127.0.0.1:8080/repository/internal/       |
       | http_proxy         | 127.0.0.1:8080                                   |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:mirror[ns:id='mirror.default'][ns:url='http://127.0.0.1:8080/repository/internal/'][ns:mirrorOf='external:*']

  # proxy auth configuration (success case) + nonProxyHosts
  Scenario: run the s2i and check the maven mirror, proxy (including username and password) and non proxy have been initialised in the default settings.xml, uses http_proxy
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | http_proxy         | myuser:mypass@127.0.0.1:8080                     |
       | no_proxy           | *.example.com                                    |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080'][ns:username='myuser'][ns:password='mypass'][ns:nonProxyHosts='*.example.com']

  # proxy auth configuration (fail case: no password supplied)
  Scenario: run the s2i and check the maven mirror, proxy (including username) and non proxy have been initialised in the default settings.xml, uses http_proxy
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | http_proxy         | myuser@127.0.0.1:8080                            |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']

  # handles mirror/repository configuration; proxy configuration
  Scenario: run the s2i and check the maven mirror and proxy have been initialised in the default settings.xml, uses http_proxy
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | MAVEN_MIRROR_URL   | http://127.0.0.1:8080/repository/internal/       |
       | http_proxy         | 127.0.0.1:8080                                   |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:mirror[ns:id='mirror.default'][ns:url='http://127.0.0.1:8080/repository/internal/'][ns:mirrorOf='external:*']

  # HTTP_PROXY (all caps) ignored
  Scenario: run the s2i and check the maven mirror and proxy have been initialised in the default settings.xml, uses http_proxy and HTTP_PROXY
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | http_proxy         | 127.0.0.2:9090                                   |
       | HTTP_PROXY         | 127.0.0.1:8080                                   |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.2'][ns:port='9090']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 0 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']

  # handles mirror/repository configuration; https proxy configuration
  Scenario: run the s2i and check the maven mirror and proxy have been initialised in the default settings.xml, uses https_proxy
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | MAVEN_MIRROR_URL   | http://127.0.0.1:8080/repository/internal/       |
       | https_proxy        | 127.0.0.1:8080                                   |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='https'][ns:host='127.0.0.1'][ns:port='8080']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:mirror[ns:id='mirror.default'][ns:url='http://127.0.0.1:8080/repository/internal/'][ns:mirrorOf='external:*']

  # https proxy auth configuration (success case) + nonProxyHosts
  Scenario: run the s2i and check the maven mirror, proxy (including username and password) and non proxy have been initialised in the default settings.xml, uses https_proxy
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | https_proxy        | myuser:mypass@127.0.0.1:8080                     |
       | no_proxy           | *.example.com                                    |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='https'][ns:host='127.0.0.1'][ns:port='8080'][ns:username='myuser'][ns:password='mypass'][ns:nonProxyHosts='*.example.com']

  # https proxy auth configuration (fail case: no password supplied)
  Scenario: run the s2i and check the maven mirror, proxy (including username) and non proxy have been initialised in the default settings.xml, uses https_proxy
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | https_proxy        | myuser@127.0.0.1:8080                            |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='https'][ns:host='127.0.0.1'][ns:port='8080']

  Scenario: run s2i assemble and check no_proxy is honoured with multiple entries
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | MAVEN_MIRROR_URL   | http://127.0.0.1:8080/repository/internal/       |
       | http_proxy         | http://127.0.0.1:8080                            |
       | no_proxy           | foo.example.com,bar.example.com                  |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080'][ns:nonProxyHosts='foo.example.com|bar.example.com']

  # deprecated?
  Scenario: run an S2I build that depends on com.redhat.xpaas.repo.redhatga being defined
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple

  # deprecated?
  Scenario: run an S2I that should fail as MAVEN_ARGS does not define com.redhat.xpaas.repo.redhatga
    Given failing s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple using openjdk-enforce-profile
       | variable           | value                                            |
       | MAVEN_ARGS         | -e package                                       |

  # CLOUD-579
  Scenario: Test that maven is executed in batch mode
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple
    Then s2i build log should contain --batch-mode
    And s2i build log should not contain \r

  # CLOUD-3095 - context dir should be recursively copied into the image
  # "/target" suffix is important here; it triggers a different code-path (no source build)
  Scenario: Ensure binary-only mode copies binaries into the target image
    Given s2i build https://github.com/jboss-openshift/openshift-examples from spring-boot-sample-simple/target
    Then s2i build log should not contain skipping directory .
    And  run find /deployments in container and check its output for spring-boot-sample-simple-1.5.0.BUILD-SNAPSHOT.jar

  Scenario: Ensure the environment is cleaned when executing mvn (OPENJDK-1549)
      Given s2i build https://github.com/jmtd/openjdk from tests/OPENJDK-1549 with env using OPENJDK-1549-MAVEN_ARGS
       | variable           | value    |
       | MAVEN_ARGS         | validate |
