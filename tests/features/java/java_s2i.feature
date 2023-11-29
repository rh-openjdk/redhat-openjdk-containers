# temporarily marking 'ignore' so these tests are skipped on GHA
@ignore
@ubi9/openjdk-11
@ubi9/openjdk-17
@ubi9/openjdk-21
Feature: Openshift OpenJDK S2I tests
# '/target' suffix triggers a binary-only build path. We use this a lot for unrelated
# tests here for speed. Most of these tests do not actually run Maven: this is important
# when the test specifies e.g. a dummy HTTP proxy value

  Scenario: run s2i and check settings.xml is configured for maven mirror and http proxy
   Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
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
  Scenario: run s2i and check settings.xml is configured for http proxy including user,pass and nonProxyHosts
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | http_proxy         | myuser:mypass@127.0.0.1:8080                     |
       | no_proxy           | *.example.com                                    |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080'][ns:username='myuser'][ns:password='mypass'][ns:nonProxyHosts='*.example.com']

  Scenario: run s2i and check settings.xml is configured for http proxy including user (no password)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | http_proxy         | myuser@127.0.0.1:8080                            |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']

  # HTTP_PROXY (all caps) ignored
  Scenario: run s2i, check http_proxy overrides HTTP_PROXY
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | http_proxy         | 127.0.0.2:9090                                   |
       | HTTP_PROXY         | 127.0.0.1:8080                                   |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.2'][ns:port='9090']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 0 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080']

  Scenario: run s2i and check settings.xml is configured for https proxy
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | https_proxy        | 127.0.0.1:8080                                   |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='https'][ns:host='127.0.0.1'][ns:port='8080']

  Scenario: run s2i and check settings.xml is configured for https proxy (including user and pass) and nonProxyHosts
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | https_proxy        | myuser:mypass@127.0.0.1:8080                     |
       | no_proxy           | *.example.com                                    |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='https'][ns:host='127.0.0.1'][ns:port='8080'][ns:username='myuser'][ns:password='mypass'][ns:nonProxyHosts='*.example.com']

  Scenario: run s2i and check settings.xml is configured for https proxy (without user and pass) when user only specified
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | https_proxy        | myuser@127.0.0.1:8080                            |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='https'][ns:host='127.0.0.1'][ns:port='8080']

  Scenario: run s2i and check no_proxy is honoured with multiple entries
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable           | value                                            |
       | MAVEN_ARGS         | -v                                               |
       | http_proxy         | http://127.0.0.1:8080                            |
       | no_proxy           | foo.example.com,bar.example.com                  |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:proxy[ns:id='genproxy'][ns:active='true'][ns:protocol='http'][ns:host='127.0.0.1'][ns:port='8080'][ns:nonProxyHosts='foo.example.com|bar.example.com']

  Scenario: Test that maven is executed in batch mode (CLOUD-579)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple
    Then s2i build log should contain --batch-mode
    And s2i build log should not contain \r

  Scenario: Ensure binary-only mode recursively copies binaries into the target image (CLOUD-3095)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
    Then s2i build log should not contain skipping directory .
    And  run find /deployments in container and check its output for spring-boot-sample-simple-1.5.0.BUILD-SNAPSHOT.jar

  Scenario: run s2i and check multiple MAVEN_REPOS have been defined in settings.xml (OPENJDK-1954)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable                | value                                |
       | MAVEN_REPOS             | TESTREPO,ANOTHER                     |
       | TESTREPO_MAVEN_REPO_URL | http://repo.example.com:8080/maven2/ |
       | TESTREPO_MAVEN_REPO_ID  | myrepo                               |
       | ANOTHER_MAVEN_REPO_URL  | https://repo.example.org:8888/       |
       | ANOTHER_MAVEN_REPO_ID   | another                              |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:server[ns:id='myrepo']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:profile[ns:id='myrepo-profile']/ns:repositories/ns:repository[ns:url='http://repo.example.com:8080/maven2/']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:server[ns:id='another']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:profile[ns:id='another-profile']/ns:repositories/ns:repository[ns:url='https://repo.example.org:8888/']

  Scenario: Check MAVEN_REPO_URL and MAVEN_REPO_ID generate Maven server and profile configuration (OPENJDK-1961)
    Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from spring-boot-sample-simple/target
       | variable       | value                                |
       | MAVEN_REPO_URL | http://repo.example.com:8080/maven2/ |
       | MAVEN_REPO_ID  | myrepo                               |
    And XML namespaces
       | prefix | url                                    |
       | ns     | http://maven.apache.org/SETTINGS/1.0.0 |
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:server[ns:id='myrepo']
    Then XML file /tmp/artifacts/configuration/settings.xml should have 1 elements on XPath //ns:profile[ns:id='myrepo-profile']/ns:repositories/ns:repository[ns:url='http://repo.example.com:8080/maven2/']

  # This synthetic maven project has a lifecycle stage 'validate' configured to fail if MAVEN_ARGS is defined
  # in the environment
  Scenario: Ensure the environment is cleaned when executing mvn (OPENJDK-1549)
      Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from OPENJDK-1549 with env
       | variable           | value    |
       | MAVEN_ARGS         | validate |

  Scenario: Ensure that run-env.sh placed in the JAVA_APP_DIR is sourced in the run script before launching java (OPENJDK-2200)
      Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from quarkus-quickstarts/getting-started-3.0.1.Final-nos2i
       | variable            | value        |
       | S2I_SOURCE_DATA_DIR | ./           |
       | S2I_TARGET_DATA_DIR | /deployments |
      Then container log should contain INFO exec -a "someUniqueString" java

  # This application source includes an override for s2i assemble which ensures there's
  # a delay of 1 sec between invocation and delegating to the image's assemble. This is
  # to catch the situation where the copy-artifacts stage of assemble does not preserve
  # artifact timestamps.
  Scenario: Ensure mtime is preserved for build artifacts (OPENJDK-2408)
      Given s2i build https://github.com/jboss-container-images/openjdk-test-applications from OPENJDK-2408-bin-custom-s2i-assemble with env
       | variable          | value |
       | S2I_DELETE_SOURCE | false |
    Then run find /deployments/spring-boot-sample-simple-1.5.0.BUILD-SNAPSHOT.jar ! -newer /tmp/src/spring-boot-sample-simple-1.5.0.BUILD-SNAPSHOT.jar in container and check its output for spring-boot-sample-simple-1.5.0.BUILD-SNAPSHOT.jar
