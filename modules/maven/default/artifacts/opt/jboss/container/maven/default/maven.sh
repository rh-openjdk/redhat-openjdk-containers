# common shell routines for use with maven
source "$JBOSS_CONTAINER_UTIL_LOGGING_MODULE/logging.sh"

# default settings.xml file
__JBOSS_MAVEN_DEFAULT_SETTINGS_FILE="${HOME}/.m2/settings.xml"

# initialize maven
function maven_init() {
  maven_init_vars
  maven_init_settings
  maven_init_local_repo
}

# initialize maven variables
function maven_init_vars() {
  maven_init_var_MAVEN_LOCAL_REPO
  maven_init_var_MAVEN_SETTINGS_XML
  maven_init_var_MAVEN_OPTS
  maven_init_var_MAVEN_ARGS
}

function maven_init_var_MAVEN_LOCAL_REPO() {
  MAVEN_LOCAL_REPO="${MAVEN_LOCAL_REPO:-${HOME}/.m2/repository}"
}

function maven_init_var_MAVEN_SETTINGS_XML() {
  if [ -f "${MAVEN_SETTINGS_XML}" ]; then
    :
  elif [ -f "${HOME}/.m2/settings.xml" ]; then
    MAVEN_SETTINGS_XML="${HOME}/.m2/settings.xml"
  else
    MAVEN_SETTINGS_XML="${JBOSS_CONTAINER_MAVEN_DEFAULT_MODULE}/jboss-settings.xml"
  fi
}

function maven_init_var_MAVEN_OPTS() {
  export MAVEN_OPTS="${MAVEN_OPTS:-$(${JBOSS_CONTAINER_JAVA_JVM_MODULE}/java-default-options) -XX:MaxRAMPercentage=25.0}"
}

function maven_init_var_MAVEN_ARGS() {
  # Add jkube.skip for apps that are using jkube's openshift-maven-plugin (OPENJDK-242)
  MAVEN_ARGS=${MAVEN_ARGS:--e -Popenshift -DskipTests -Dcom.redhat.xpaas.repo.redhatga -Djkube.skip=true}
  # Use maven batch mode (CLOUD-579)
  # Always force IPv4 (CLOUD-188)
  MAVEN_ARGS="$MAVEN_ARGS --batch-mode -Djava.net.preferIPv4Stack=true"
  # manually configure settings (to simplify using custom settings vs default)
  MAVEN_ARGS="$MAVEN_ARGS -s ${MAVEN_SETTINGS_XML}"
  # manually configure local repository (to simplify configuration of custom vs default)
  MAVEN_ARGS="$MAVEN_ARGS -Dmaven.repo.local=${MAVEN_LOCAL_REPO}"

  # Append user-supplied arguments (CLOUD-412)
  MAVEN_ARGS="$MAVEN_ARGS ${MAVEN_ARGS_APPEND}"
}

function maven_init_settings() {
  process_maven_settings_xml "${MAVEN_SETTINGS_XML}"
}

function maven_init_local_repo() {
  :
}

# perform a maven build
# $1 build directory; defaults to cwd
# $2 goals to execute; defaults to package
# e.g. cd $1; mvn $2
function maven_build() {
  local build_dir=${1:-$(cwd)}
  local goals=${2:-package}
  log_info "Performing Maven build in $build_dir"

  pushd $build_dir &> /dev/null

  log_info "Using MAVEN_OPTS ${MAVEN_OPTS}"
  log_info "Using $(mvn $MAVEN_ARGS --version)"
  log_info "Running 'mvn $MAVEN_ARGS $goals'"

  # Execute the actual build (ensuring MAVEN_ARGS is unset, OPENJDK-1549)
  REAL_MAVEN_ARGS="$MAVEN_ARGS"
  unset MAVEN_ARGS
  mvn $REAL_MAVEN_ARGS $goals
  
  popd &> /dev/null
  
}

# post build cleanup.  deletes local repository after a build, if MAVEN_CLEAR_REPO is set
function maven_cleanup() { 
  # Remove repo if desired
  if [ "${MAVEN_CLEAR_REPO,,}" == "true" -a -n "$(find ${MAVEN_LOCAL_REPO} -maxdepth 0 -type d ! -empty 2> /dev/null)" ]; then
    log_info "Clearing local maven repository at ${MAVEN_LOCAL_REPO}"
    rm -rf "${MAVEN_LOCAL_REPO}"
    if [ $? -ne 0 ]; then
      log_error "Cannot remove local Maven repository ${MAVEN_LOCAL_REPO}"
    fi
  fi
}

# apply environment to settings.xml file
function process_maven_settings_xml() {
  local settings="${1:-${__JBOSS_MAVEN_DEFAULT_SETTINGS_FILE}}"
  add_maven_proxy_settings "${settings}"
  add_maven_mirrors "${settings}"
  add_maven_repos "${settings}"
}

# add proxy configuration to settings.xml
# internal function, use process_maven_settings_xml which applies all configuration
function add_maven_proxy_settings() {
  local settings="$1"

  if [ -n "${https_proxy}" ] ; then
    source "$JBOSS_CONTAINER_JAVA_PROXY_MODULE"/parse-proxy-url.sh "${https_proxy}" https 443
  else
    if [ -n "${http_proxy}" ] ; then
      source "$JBOSS_CONTAINER_JAVA_PROXY_MODULE"/parse-proxy-url.sh "${http_proxy}" http 80
    fi
  fi
  _add_maven_proxy "${settings}"
}

# insert settings for HTTP proxy into settings.xml if supplied as
# separate variables JAVA_PROXY_HOST, _PORT, _SCHEME, _USERNAME,
# _PASSWORD, _NONPROXYHOSTS
# internal function
function _add_maven_proxy() {
  local settings="${1:-${__JBOSS_MAVEN_DEFAULT_SETTINGS_FILE}}"
  if [ -n "$JAVA_PROXY_HOST" -a -n "$JAVA_PROXY_PORT" ]; then
    xml="<proxy>\
         <id>genproxy</id>\
         <active>true</active>\
         <protocol>${JAVA_PROXY_SCHEME:-http}</protocol>\
         <host>$JAVA_PROXY_HOST</host>\
         <port>$JAVA_PROXY_PORT</port>"
    if [ -n "$JAVA_PROXY_USERNAME" -a -n "$JAVA_PROXY_PASSWORD" ]; then
      xml="$xml\
         <username>$JAVA_PROXY_USERNAME</username>\
         <password>$JAVA_PROXY_PASSWORD</password>"
    fi
    source "$JBOSS_CONTAINER_JAVA_PROXY_MODULE"/translate-no-proxy.sh
    if [ -n "$JAVA_PROXY_NONPROXYHOSTS" ]; then
      xml="$xml\
         <nonProxyHosts>$JAVA_PROXY_NONPROXYHOSTS</nonProxyHosts>"
    fi
  xml="$xml\
       </proxy>"
    local sub="<!-- ### configured http proxy ### -->"
    sed -i "s^${sub}^${xml}^" "$settings"
  fi
}

# Finds the environment variable  and returns its value if found.
# Otherwise returns the default value if provided.
#
# Arguments:
# $1 env variable name to check
# $2 default value if environment variable was not set
function _maven_find_env() {
  local var=${!1}
  echo "${var:-$2}"
}

# Finds the environment variable with the given prefix. If not found
# the default value will be returned. If no prefix is provided will
# rely on _maven_find_env
#
# Arguments
#  - $1 prefix. Transformed to uppercase and replace - by _
#  - $2 variable name. Prepended by "prefix_"
#  - $3 default value if the variable is not defined
function _maven_find_prefixed_env() {
  local prefix=$1

  if [[ -z $prefix ]]; then
    _maven_find_env $2 $3
  else
    prefix=${prefix^^} # uppercase
    prefix=${prefix//-/_} #replace - by _

    local var_name=$prefix"_"$2
    echo ${!var_name:-$3}
  fi
}
# insert settings for mirrors/repository managers into settings.xml if supplied
# internal function, use process_maven_settings_xml which applies all configuration
function add_maven_mirrors() {
  local settings="${1:-${__JBOSS_MAVEN_DEFAULT_SETTINGS_FILE}}"
  local counter=1

  # Be backwards compatible
  if [ -n "${MAVEN_MIRROR_URL}" ]; then
    local mirror_id=$(_maven_find_env "MAVEN_MIRROR_ID" "mirror.default")
    local mirror_of=$(_maven_find_env "MAVEN_MIRROR_OF" "external:*")

    _add_maven_mirror "${settings}" "${mirror_id}" "${MAVEN_MIRROR_URL}" "${mirror_of}"
  fi

  IFS=',' read -a maven_mirror_prefixes <<< ${MAVEN_MIRRORS}
  for maven_mirror_prefix in ${maven_mirror_prefixes[@]}; do
    local mirror_id=$(_maven_find_prefixed_env "${maven_mirror_prefix}" "MAVEN_MIRROR_ID" "mirror${counter}")
    local mirror_url=$(_maven_find_prefixed_env "${maven_mirror_prefix}" "MAVEN_MIRROR_URL")
    local mirror_of=$(_maven_find_prefixed_env "${maven_mirror_prefix}" "MAVEN_MIRROR_OF" "external:*")

    if [ -z "${mirror_url}" ]; then
      log_warning "Variable \"${maven_mirror_prefix}_MAVEN_MIRROR_URL\" not set. Skipping maven mirror setup for the prefix \"${maven_mirror_prefix}\"."
    else
      _add_maven_mirror "${settings}" "${mirror_id}" "${mirror_url}" "${mirror_of}"
    fi

    counter=$((counter+1))
  done
}

# private
function _add_maven_mirror() {
  local settings="${1}"
  local mirror_id="${2}"
  local mirror_url="${3}"
  local mirror_of="${4}"

  local xml="<mirror>\n\
      <id>${mirror_id}</id>\n\
      <url>${mirror_url}</url>\n\
      <mirrorOf>${mirror_of}</mirrorOf>\n\
    </mirror>\n\
    <!-- ### configured mirrors ### -->"

  sed -i "s|<!-- ### configured mirrors ### -->|$xml|" "${settings}"

}

function add_maven_repos() {
  local settings="${1}"

  # set the local repository
  local local_repo_xml="\n\
  <localRepository>${MAVEN_LOCAL_REPO}</localRepository>"
  sed -i "s|<!-- ### configured local repository ### -->|${local_repo_xml}|" "${settings}"

  # single remote repository scenario: respect fully qualified url if specified, otherwise find and use service
  local single_repo_url="${MAVEN_REPO_URL}"
  if [ -n "$single_repo_url" ]; then
    local single_repo_id=$(_maven_find_env "MAVEN_REPO_ID" "repo-$(_generate_random_id)")
    add_maven_repo "$settings" "$single_repo_url" "$single_repo_id"
  fi

  # multiple remote repositories scenario: respect fully qualified url(s) if specified, otherwise find and use service(s); can be used together with "single repo scenario" above
  local multi_repo_counter=1
  IFS=',' read -a multi_repo_prefixes <<< ${MAVEN_REPOS}
  for multi_repo_prefix in ${multi_repo_prefixes[@]}; do
    local multi_repo_url=$(_maven_find_prefixed_env "${multi_repo_prefix}" "MAVEN_REPO_URL")
    local multi_repo_id=$(_maven_find_prefixed_env "${multi_repo_prefix}" "MAVEN_REPO_ID" "repo${multi_repo_counter}-$(_generate_random_id)")
    add_maven_repo "$settings" "$multi_repo_url" "$multi_repo_id" "$multi_repo_prefix"
    multi_repo_counter=$((multi_repo_counter+1))
  done
}

function add_maven_repo() {
  local settings=$1
  local repo_url=$2
  local repo_id=$3
  if [[ -z $4 ]]; then
    local prefix="MAVEN"
  else
    local prefix="${4}_MAVEN"
  fi

  if [[ -z ${repo_url} ]]; then
      local repo_service=$(_maven_find_prefixed_env "${prefix}" "REPO_SERVICE")
      # host
      local repo_host=$(_maven_find_prefixed_env "${prefix}" "REPO_HOST")
      if [[ -z ${repo_host} ]]; then
        repo_host=$(_maven_find_prefixed_env "${repo_service}" "SERVICE_HOST")
      fi
      if [[ ! -z ${repo_host} ]]; then
        # protocol
        local repo_protocol=$(_maven_find_prefixed_env "${prefix}" "REPO_PROTOCOL" "http")
        # port
        local repo_port=$(_maven_find_prefixed_env "${prefix}" "REPO_PORT")
        if [ "${repo_port}" = "" ]; then
          repo_port=$(_maven_find_prefixed_env "${repo_service}" "SERVICE_PORT" "8080")
        fi
        local repo_path=$(_maven_find_prefixed_env "${prefix}" "REPO_PATH")
        # strip leading slash if exists
        if [[ "${repo_path}" =~ ^/ ]]; then
          repo_path="${repo_path:1:${#repo_path}}"
        fi
        # url
        repo_url="${repo_protocol}://${repo_host}:${repo_port}/${repo_path}"
      fi
  fi
  if [[ ! -z ${repo_url} ]]; then
    _add_maven_repo_profile "${settings}" "${repo_id}" "${repo_url}" "${prefix}"
    _add_maven_repo_server "${settings}" "${repo_id}" "${prefix}"
  else
    log_warning "Variable \"${prefix}_REPO_URL\" not set. Skipping maven repo setup for the prefix \"${prefix}\"."
  fi
}

# private
function _add_maven_repo_profile() {
  local settings=$1
  local repo_id=$2
  local url=$3
  local prefix=$4

  local name=$(_maven_find_prefixed_env "${prefix}" "REPO_NAME" "${repo_id}")
  local layout=$(_maven_find_prefixed_env "${prefix}" "REPO_LAYOUT" "default")
  local releases_enabled=$(_maven_find_prefixed_env "${prefix}" "REPO_RELEASES_ENABLED" "true")
  local releases_update_policy=$(_maven_find_prefixed_env "${prefix}" "REPO_RELEASES_UPDATE_POLICY" "always")
  local releases_checksum_policy=$(_maven_find_prefixed_env "${prefix}" "REPO_RELEASES_CHECKSUM_POLICY" "warn")
  local snapshots_enabled=$(_maven_find_prefixed_env "${prefix}" "REPO_SNAPSHOTS_ENABLED" "true")
  local snapshots_update_policy=$(_maven_find_prefixed_env "${prefix}" "REPO_SNAPSHOTS_UPDATE_POLICY" "always")
  local snapshots_checksum_policy=$(_maven_find_prefixed_env "${prefix}" "REPO_SNAPSHOTS_CHECKSUM_POLICY" "warn")

  # configure the repository in a profile
  local profile_id="${repo_id}-profile"
  local xml="\n\
  <profile>\n\
    <id>${profile_id}</id>\n\
    <repositories>\n\
      <repository>\n\
        <id>${repo_id}</id>\n\
        <name>${name}</name>\n\
        <url>${url}</url>\n\
        <layout>${layout}</layout>\n\
        <releases>\n\
          <enabled>${releases_enabled}</enabled>\n\
          <updatePolicy>${releases_update_policy}</updatePolicy>\n\
          <checksumPolicy>${releases_checksum_policy}</checksumPolicy>\n\
        </releases>\n\
        <snapshots>\n\
          <enabled>${snapshots_enabled}</enabled>\n\
          <updatePolicy>${snapshots_update_policy}</updatePolicy>\n\
          <checksumPolicy>${snapshots_checksum_policy}</checksumPolicy>\n\
        </snapshots>\n\
      </repository>\n\
    </repositories>\n\
  </profile>\n\
  <!-- ### configured profiles ### -->"
  sed -i "s|<!-- ### configured profiles ### -->|${xml}|" "${settings}"

  # activate the configured profile
  xml="\n\
    <activeProfile>${profile_id}</activeProfile>\n\
    <!-- ### active profiles ### -->"
  sed -i "s|<!-- ### active profiles ### -->|${xml}|" "${settings}"
}

# private
function _add_maven_repo_server() {
  local settings=$1
  local server_id=$2
  local prefix=$3

  local username=$(_maven_find_prefixed_env "$prefix" "REPO_USERNAME")
  local password=$(_maven_find_prefixed_env "$prefix" "REPO_PASSWORD")
  local private_key=$(_maven_find_prefixed_env "$prefix" "REPO_PRIVATE_KEY")
  local passphrase=$(_maven_find_prefixed_env "$prefix" "REPO_PASSPHRASE")
  local file_permissions=$(_maven_find_prefixed_env "$prefix" "REPO_FILE_PERMISSIONS")
  local directory_permissions=$(_maven_find_prefixed_env "$prefix" "REPO_DIRECTORY_PERMISSIONS")

  local xml="\n\
    <server>\n\
      <id>${server_id}</id>"
  if [ "${username}" != "" -a "${password}" != "" ]; then
    xml="${xml}\n\
      <username>${username}</username>\n\
      <password><![CDATA[${password}]]></password>"
  fi
  if [ "${private_key}" != "" -a "${passphrase}" != "" ]; then
    xml="${xml}\n\
      <privateKey>${private_key}</privateKey>\n\
      <passphrase><![CDATA[${passphrase}]]></passphrase>"
  fi
  if [ "${file_permissions}" != "" ]; then
    xml="${xml}\n\
      <filePermissions>${file_permissions}</filePermissions>"
  fi
  if [ "${directory_permissions}" != "" ]; then
    xml="${xml}\n\
      <directoryPermissions>${directory_permissions}</directoryPermissions>"
  fi
  xml="${xml}\n\
    </server>\n\
    <!-- ### configured servers ### -->"
  sed -i "s|<!-- ### configured servers ### -->|${xml}|" "${settings}"
}

# private
function _generate_random_id() {
  cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}
