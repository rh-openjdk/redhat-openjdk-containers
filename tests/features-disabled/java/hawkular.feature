@redhat-openjdk-18 @redhat-openjdk-11
@centos/openjdk-18-centos7
Feature: Openshift OpenJDK Hawkular tests

   Scenario: Check default Hawkular
     Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
     Then container log should not contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10 

   # Need to mount an actual keystore to test security-realm configuration
   @ignore
   Scenario: Check full Hawkular configuration
     Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                            | value                           |
       | AB_HAWKULAR_REST_URL                | https://hawkular:5280/hawkular  |
       | AB_HAWKULAR_REST_USER               | hawkW1nd                        |
       | AB_HAWKULAR_REST_PASSWORD           | QSandC77!                       |
       | AB_HAWKULAR_REST_FEED_ID            | project:podid                   |
       | AB_HAWKULAR_REST_TENANT_ID          | project                         |
       | AB_HAWKULAR_REST_KEYSTORE           | keystore.jks                    |
       | AB_HAWKULAR_REST_KEYSTORE_DIR       | /etc/hawkular-agent-volume      |
       | AB_HAWKULAR_REST_KEYSTORE_PASSWORD  | 53same!                         |
     Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
       And container log should contain -Dhawkular.agent.in-container = true
       And container log should contain -Dhawkular.rest.user=hawkW1nd
       And container log should contain -Dhawkular.rest.password=QSandC77!
       And container log should contain -Dhawkular.rest.host=https://hawkular:5280/hawkular
       And container log should contain -Dhawkular.rest.tenantId=project
       And container log should contain -Dhawkular.rest.feedId=project:podid
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain security-realm: HawkularRealm
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should contain name: HawkularRealm

   Scenario: Check unsecured Hawkular configuration
     Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                            | value                           |
       | AB_HAWKULAR_REST_URL                | http://hawkular:5280/hawkular   |
       | AB_HAWKULAR_REST_USER               | hawkW1nd                        |
       | AB_HAWKULAR_REST_PASSWORD           | QSandC77!                       |
     Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
       And container log should contain -Dhawkular.agent.in-container=true
       And container log should contain -Dhawkular.rest.user=hawkW1nd
       And container log should contain -Dhawkular.rest.password=QSandC77!
       And container log should contain -Dhawkular.rest.host=http://hawkular:5280/hawkular
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

   Scenario: Check error on Hawkular configuration without keystore
     Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                            | value                           |
       | AB_HAWKULAR_REST_URL                | https://hawkular:5280/hawkular  |
       | AB_HAWKULAR_REST_USER               | hawkW1nd                        |
       | AB_HAWKULAR_REST_PASSWORD           | QSandC77!                       |
     Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
       And container log should contain -Dhawkular.agent.in-container=true
       And container log should contain -Dhawkular.rest.user=hawkW1nd
       And container log should contain -Dhawkular.rest.password=QSandC77!
       And container log should contain -Dhawkular.rest.host=https://hawkular:5280/hawkular
       And container log should contain WARN No AB_HAWKULAR_REST_KEYSTORE configuration defined.  HawkularRealm security-realm will not be configured and https access to the Hawkular REST service may fail.
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

   Scenario: Check error on Hawkular configuration with partial keystore
     Given s2i build https://github.com/jboss-openshift/openshift-quickstarts from undertow-servlet
       | variable                            | value                           |
       | AB_HAWKULAR_REST_URL                | https://hawkular:5280/hawkular  |
       | AB_HAWKULAR_REST_USER               | hawkW1nd                        |
       | AB_HAWKULAR_REST_PASSWORD           | QSandC77!                       |
       | AB_HAWKULAR_REST_KEYSTORE           | keystore.jks                    |
     Then container log should contain -javaagent:/opt/jboss/container/hawkular/hawkular-javaagent.jar=config=/opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml,delay=10
       And container log should contain -Dhawkular.agent.in-container=true
       And container log should contain -Dhawkular.rest.user=hawkW1nd
       And container log should contain -Dhawkular.rest.password=QSandC77!
       And container log should contain -Dhawkular.rest.host=https://hawkular:5280/hawkular
       And container log should contain WARN Partial AB_HAWKULAR_REST_KEYSTORE configuration defined.  HawkularRealm security-realm will not be configured and https access to the Hawkular REST service may fail.
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain security-realm: HawkularRealm
       And file /opt/jboss/container/hawkular/etc/hawkular-javaagent-config.yaml should not contain name: HawkularRealm

