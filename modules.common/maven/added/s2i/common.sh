# common shell routines for s2i scripts

# insert settings for HTTP proxy into settings.xml if supplied as
# separate variables HTTP_PROXY_HOST, _PORT, _SCHEME, _USERNAME,
# _PASSWORD, _NONPROXYHOSTS
function configure_proxy_write() {
  local settings="${1:-$HOME/.m2/settings.xml}"
  if [ -n "$HTTP_PROXY_HOST" -a -n "$HTTP_PROXY_PORT" ]; then
    xml="<proxy>\
         <id>genproxy</id>\
         <active>true</active>\
         <protocol>${HTTP_PROXY_SCHEME:-http}</protocol>\
         <host>$HTTP_PROXY_HOST</host>\
         <port>$HTTP_PROXY_PORT</port>"
    if [ -n "$HTTP_PROXY_USERNAME" -a -n "$HTTP_PROXY_PASSWORD" ]; then
      xml="$xml\
         <username>$HTTP_PROXY_USERNAME</username>\
         <password>$HTTP_PROXY_PASSWORD</password>"
    fi
    if [ -n "$HTTP_PROXY_NONPROXYHOSTS" ]; then
      xml="$xml\
         <nonProxyHosts>$HTTP_PROXY_NONPROXYHOSTS</nonProxyHosts>"
    fi
  xml="$xml\
       </proxy>"
    local sub="<!-- ### configured http proxy ### -->"
    sed -i "s^${sub}^${xml}^" "$settings"
  fi
}

# break a supplied url (as would be in HTTP_PROXY) up into constituent bits and
# export the bits as variables that match our old scheme for configuring proxies
# $settings - file to edit
function configure_proxy_url() {
  local url="$1"
  local default_scheme="$2"
  local default_port="$3"
  if [ -n "$url" ] ; then
    #[scheme://][user[:password]@]host[:port][/path][?params]
    eval $(echo "$1" | sed -e "s+^\(\([^:]*\)://\)\?\(\([^:@]*\)\(:\([^@]*\)\)\?@\)\?\([^:/?]*\)\(:\([^/?]*\)\)\?.*$+HTTP_PROXY_SCHEME='\2' HTTP_PROXY_USERNAME='\4' HTTP_PROXY_PASSWORD='\6' HTTP_PROXY_HOST='\7' HTTP_PROXY_PORT='\9'+")

    HTTP_PROXY_SCHEME="${HTTP_PROXY_SCHEME:-$default_scheme}"
    HTTP_PROXY_PORT="${HTTP_PROXY_PORT:-$default_port}"

    local noProxy="${no_proxy:-${NO_PROXY}}"
    if [ -n "$noProxy" ]; then
        HTTP_PROXY_NONPROXYHOSTS="${noProxy//,/|}"
    fi
  fi
}

function configure_proxy() {
  local httpsProxy="${https_proxy:-${HTTPS_PROXY}}"
  local httpProxy="${http_proxy:-${HTTP_PROXY}}"
  local settings="$1"

  if [ -n "${httpsProxy}" ] ; then
    configure_proxy_url "${httpsProxy}" https 443
  else
    if [ -n "${httpProxy}" ] ; then
      configure_proxy_url "${httpProxy}" http 80
    fi
  fi
  configure_proxy_write "${settings}"
}

function find_env() {
  local var=${!1}
  echo "${var:-$2}"
}

# insert settings for mirrors/repository managers into settings.xml if supplied
function configure_mirrors() {
  local settings="${1-$HOME/.m2/settings.xml}"
  local counter=1

  # Be backwards compatible
  if [ -n "${MAVEN_MIRROR_URL}" ]; then
    local mirror_id=$(find_env "MAVEN_MIRROR_ID" "mirror.default")
    local mirror_of=$(find_env "MAVEN_MIRROR_OF" "external:*")

    configure_mirror "${settings}" "${mirror_id}" "${MAVEN_MIRROR_URL}" "${mirror_of}"
  fi

  IFS=',' read -a maven_mirror_prefixes <<< ${MAVEN_MIRRORS}
  for maven_mirror_prefix in ${maven_mirror_prefixes[@]}; do
    local mirror_id=$(find_env "${maven_mirror_prefix}_MAVEN_MIRROR_ID" "mirror${counter}")
    local mirror_url=$(find_env "${maven_mirror_prefix}_MAVEN_MIRROR_URL")
    local mirror_of=$(find_env "${maven_mirror_prefix}_MAVEN_MIRROR_OF" "external:*")

    if [ -z "${mirror_url}" ]; then
      echo "WARNING: Variable \"${maven_mirror_prefix}_MAVEN_MIRROR_URL\" not set. Skipping maven mirror setup for the prefix \"${maven_mirror_prefix}\"."
    else
      configure_mirror "${settings}" "${mirror_id}" "${mirror_url}" "${mirror_of}"
    fi

    counter=$((counter+1))
  done
}

function configure_mirror() {
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

# copy all artifacts of types, specified as the second up to n-th
# argument of the routine into the $DEPLOY_DIR directory
# Requires: source directory expressed in the form of absolute path!
function copy_artifacts() {
  dir=$1
  types=
  shift
  while [ $# -gt 0 ]; do
    types="$types;$1"
    shift
  done
  
  for d in $(echo $dir | tr "," "\n")
  do
    shift
    local regex="^\/"
    if [[ ! "$d" =~ $regex ]]; then
      echo "$FUNCNAME: Absolute path required for source directory \"$d\"!"
      exit 1
    fi
    for t in $(echo $types | tr ";" "\n")
    do
      echo "Copying all $t artifacts from $d directory into $DEPLOY_DIR for later deployment..."
      cp -rfv $d/*.$t $DEPLOY_DIR 2> /dev/null
    done
  done
}

# handle incremental builds. If we have been passed build artifacts, untar
# them over the supplied source.
manage_incremental_build() {
    if [ -d /tmp/artifacts ]; then
        echo "Expanding artifacts from incremental build..."
        ( cd /tmp/artifacts && tar cf - . ) | ( cd ${HOME} && tar xvf - )
        rm -rf /tmp/artifacts
    fi
}

# s2i 'save-artifacts' routine
s2i_save_build_artifacts() {
    cd ${HOME}
    tar cf - .m2
}

# optionally clear the local maven repository after the build
clear_maven_repository() {
    mcr=$(echo "${MAVEN_CLEAR_REPO}" | tr [:upper:] [:lower:])
    if [ "${mcr}" = "true" ]; then
        rm -rf ${HOME}/.m2/repository/*
    fi
}
