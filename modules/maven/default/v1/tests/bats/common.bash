CCT_MODULE_DIR="${BATS_TEST_DIRNAME}/../../../../../../.."

load $CCT_MODULE_DIR/tests/bats/common/xml_utils.bash

export JBOSS_HOME=$BATS_TMPDIR/jboss_home
mkdir -p $JBOSS_HOME/bin/launch
cp $CCT_MODULE_DIR/os-eap7-launch/added/launch/launch-common.sh $JBOSS_HOME/bin/launch
cp $CCT_MODULE_DIR/jboss/container/util/logging/bash/artifacts/opt/jboss/container/util/logging/logging.sh $JBOSS_HOME/bin/launch

export HOME=$BATS_TMPDIR/home
export SETTINGS=$HOME/.m2/settings.xml
export JBOSS_CONTAINER_UTIL_LOGGING_MODULE=$CCT_MODULE_DIR/jboss/container/util/logging/bash/artifacts/opt/jboss/container/util/logging

mkdir -p $HOME/.m2

source $CCT_MODULE_DIR/jboss/container/maven/default/artifacts/opt/jboss/container/maven/default/maven.sh

setup() {
  cp $CCT_MODULE_DIR/jboss/container/maven/default/artifacts/opt/jboss/container/maven/default/jboss-settings.xml $HOME/.m2/settings.xml
}

function assert_profile_xml() {
  local profile_id=$1
  local expected=$2
  local xpath='//*[local-name()="profile"][*[local-name()="id"]="'$profile_id'"]'

  assert_xml $HOME/.m2/settings.xml $xpath $BATS_TEST_DIRNAME/expectations/$expected
}

function has_generated_profile() {
  local xpath='//*[local-name()="profile"][starts-with(*[local-name()="id"],"repo-")]/*[local-name()="id"]/text()'

  assert_xml_value $HOME/.m2/settings.xml $xpath '^repo-.*-profile$'
}

function assert_active_profile() {
  local profile_id=$1
  local xpath='//*[local-name()="activeProfile"][text()="'$profile_id'"]/text()'

  assert_xml_value $HOME/.m2/settings.xml $xpath $profile_id
}

function has_generated_active_profile() {
  local xpath='//*[local-name()="activeProfile"][starts-with(.,"repo-")]/text()'

  assert_xml_value $HOME/.m2/settings.xml $xpath '^repo-.*-profile$'
}

function assert_server_xml() {
  local profile_id=$1
  local expected=$2
  local xpath='//*[local-name()="server"][*[local-name()="id"]="'$profile_id'"]'

  assert_xml $HOME/.m2/settings.xml $xpath $BATS_TEST_DIRNAME/expectations/$expected
}

function has_generated_server() {
  local profile_regex=$1
  local xpath='//*[local-name()="server"][starts-with(*[local-name()="id"],"repo-")]/*[local-name()="id"]/text()'

  assert_xml_value $HOME/.m2/settings.xml $xpath '^repo-.*$'
}
