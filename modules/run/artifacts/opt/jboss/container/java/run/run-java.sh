#!/bin/bash

# Fail on a single failed command
set -eo pipefail

export JBOSS_CONTAINER_UTIL_LOGGING_MODULE="${JBOSS_CONTAINER_UTIL_LOGGING_MODULE-/opt/jboss/container/util/logging}"
export JBOSS_CONTAINER_JAVA_RUN_MODULE="${JBOSS_CONTAINER_JAVA_RUN_MODULE-/opt/jboss/container/java/run}"
export JBOSS_CONTAINER_UTIL_PATHFINDER_MODULE="${JBOSS_CONTAINER_UTIL_PATHFINDER_MODULE-/opt/jboss/container/util/pathfinder}"

# Default the application dir to the S2I deployment dir
if [ -z "$JAVA_APP_DIR" ]
  then JAVA_APP_DIR=/deployments
fi

source "$JBOSS_CONTAINER_UTIL_LOGGING_MODULE/logging.sh"
source "$JBOSS_CONTAINER_UTIL_PATHFINDER_MODULE/pathfinder.sh"

# ==========================================================
# Generic run script for running arbitrary Java applications
#
# This has forked (and diverged) from:
# at https://github.com/fabric8io/run-java-sh
#
# ==========================================================

# Error is indicated with a prefix in the return value
check_error() {
  local msg=$1
  if echo ${msg} | grep -q "^ERROR:"; then
    log_error ${msg}
    exit 1
  fi
}

# Combine all java options
get_java_options() {
  local jvm_opts
  local debug_opts
  local proxy_opts
  local opts
  if [ -f "${JBOSS_CONTAINER_JAVA_JVM_MODULE}/java-default-options" ]; then
    jvm_opts=$(${JBOSS_CONTAINER_JAVA_JVM_MODULE}/java-default-options)
  fi
  if [ -f "${JBOSS_CONTAINER_JAVA_JVM_MODULE}/debug-options" ]; then
    debug_opts=$(${JBOSS_CONTAINER_JAVA_JVM_MODULE}/debug-options)
  fi
  if [ -f "${JBOSS_CONTAINER_JAVA_PROXY_MODULE}/proxy-options" ]; then
    source "${JBOSS_CONTAINER_JAVA_PROXY_MODULE}/proxy-options"
    proxy_opts="$(proxy_options)"
  fi

  opts=${JAVA_OPTS-${debug_opts} ${proxy_opts} ${jvm_opts} ${JAVA_OPTS_APPEND}}
  # Normalize spaces with awk (i.e. trim and eliminate double spaces)
  echo "${opts}" | awk '$1=$1'
}

# Read in a classpath either from a file with a single line, colon separated
# or given line-by-line in separate lines
# Arg 1: path to claspath (must exist), optional arg2: application jar, which is stripped from the classpath in
# multi line arrangements
format_classpath() {
  local cp_file="$1"
  local app_jar="$2"

  local wc_out=`wc -l $1 2>&1`
  if [ $? -ne 0 ]; then
    log_error "Cannot read lines in ${cp_file}: $wc_out"
    exit 1
  fi

  local nr_lines=`echo $wc_out | awk '{ print $1 }'`
  if [ ${nr_lines} -gt 1 ]; then
    local sep=""
    local classpath=""
    while read file; do
      local full_path="${JAVA_LIB_DIR}/${file}"
      # Don't include app jar if include in list
      if [ x"${app_jar}" != x"${full_path}" ]; then
        classpath="${classpath}${sep}${full_path}"
      fi
      sep=":"
    done < "${cp_file}"
    echo "${classpath}"
  else
    # Supposed to be a single line, colon separated classpath file
    cat "${cp_file}"
  fi
}

# Fetch classpath from env or from a local "run-classpath" file
get_classpath() {
  local cp_path="."
  if [ "x${JAVA_LIB_DIR}" != "x${JAVA_APP_DIR}" ]; then
    cp_path="${cp_path}:${JAVA_LIB_DIR}"
  fi
  if [ -z "${JAVA_CLASSPATH}" ] && [ "x${JAVA_MAIN_CLASS}" != x ]; then
    if [ "x${JAVA_APP_JAR}" != x ]; then
      cp_path="${cp_path}:${JAVA_APP_JAR}"
    fi
    if [ -f "${JAVA_LIB_DIR}/classpath" ]; then
      # Classpath is pre-created and stored in a 'run-classpath' file
      cp_path="${cp_path}:`format_classpath ${JAVA_LIB_DIR}/classpath ${JAVA_APP_JAR}`"
    else
      # No order implied
      cp_path="${cp_path}:${JAVA_APP_DIR}/*"
    fi
  elif [ "x${JAVA_CLASSPATH}" != x ]; then
    # Given from the outside
    cp_path="${JAVA_CLASSPATH}"
  fi
  echo "${cp_path}"
}

# Mask secrets before printing
mask_passwords() {
    local content="$1"
    local result=""

    IFS=' ' read -r -a key_value_pairs <<< "$content"

    for pair in "${key_value_pairs[@]}"; do
        key=$(echo "$pair" | cut -d '=' -f 1)
        value=$(echo "$pair" | cut -d '=' -f 2-)

        if [[ $key =~ [Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd] ]]; then
            result+="$key=***** "
        else
            result+="$pair "
        fi
    done

    echo "${result% }"
}

# Start JVM
startup() {
  # Initialize environment
  # populates JAVA_APP_JAR and JAVA_LIB_DIR and possibly JAVA_MAIN_CLASS
  setup_java_app_and_lib

  local args
  cd ${JAVA_APP_DIR}
  if [ "x${JAVA_MAIN_CLASS}" != x ] ; then
     args="${JAVA_MAIN_CLASS}"
  else
     args="-jar ${JAVA_APP_JAR}"
  fi

  local procname="${JAVA_APP_NAME-java}"

  local masked_opts=$(mask_passwords "$(get_java_options)")

  log_info "exec -a \"${procname}\" java ${masked_opts} -cp \"$(get_classpath)\" ${args} $*"
  log_info "running in $PWD"
  exec -a "${procname}" java $(get_java_options) -cp "$(get_classpath)" ${args} $*
}

# =============================================================================
# Fire up
startup $*
