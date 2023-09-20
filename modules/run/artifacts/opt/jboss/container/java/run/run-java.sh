#!/bin/bash

# Fail on a single failed command
set -eo pipefail

export JBOSS_CONTAINER_UTIL_LOGGING_MODULE="${JBOSS_CONTAINER_UTIL_LOGGING_MODULE-/opt/jboss/container/util/logging}"
export JBOSS_CONTAINER_JAVA_RUN_MODULE="${JBOSS_CONTAINER_JAVA_RUN_MODULE-/opt/jboss/container/java/run}"

# Default the application dir to the S2I deployment dir
if [ -z "$JAVA_APP_DIR" ]
  then JAVA_APP_DIR=/deployments
fi

source "$JBOSS_CONTAINER_UTIL_LOGGING_MODULE/logging.sh"

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

# detect Quarkus fast-jar package type (OPENJDK-631)
is_quarkus_fast_jar() {
  if test -f quarkus-app/quarkus-run.jar; then
    log_info "quarkus fast-jar package type detected"
    echo quarkus-app/quarkus-run.jar
    return 0
  else
    return 1
  fi
}

# Try hard to find a sane default jar-file
auto_detect_jar_file() {
  local dir=$1

  # Filter out temporary jars from the shade plugin which start with 'original-'
  local old_dir=$(pwd)
  cd ${dir}
  if [ $? = 0 ]; then

    if quarkus="$(is_quarkus_fast_jar)"; then
      echo "$quarkus"
      return
    fi

    local nr_jars=`ls *.jar 2>/dev/null | grep -v '^original-' | wc -l | tr -d '[[:space:]]'`
    if [ ${nr_jars} = 1 ]; then
      ls *.jar | grep -v '^original-'
      exit 0
    fi

    log_error "Neither \$JAVA_MAIN_CLASS nor \$JAVA_APP_JAR is set and ${nr_jars} JARs found in ${dir} (1 expected)"
    cd ${old_dir}
  else
    log_error "No directory ${dir} found for auto detection"
  fi
}

# Check directories (arg 2...n) for a jar file (arg 1)
get_jar_file() {
  local jar=$1
  shift;

  if [ "${jar:0:1}" = "/" ]; then
    if [ -f "${jar}" ]; then
      echo "${jar}"
    else
      log_error "No such file ${jar}"
    fi
  else
    for dir in $*; do
      if [ -f "${dir}/$jar" ]; then
        echo "${dir}/$jar"
        return
      fi
    done
    log_error "No ${jar} found in $*"
  fi
}

load_env() {
  # Configuration stuff is read from this file
  local run_env_sh="run-env.sh"

  # Load default default config
  if [ -f "${JBOSS_CONTAINER_JAVA_RUN_MODULE}/${run_env_sh}" ]; then
    source "${JBOSS_CONTAINER_JAVA_RUN_MODULE}/${run_env_sh}"
  fi

  # Check also $JAVA_APP_DIR. Overrides other defaults
  # It's valid to set the app dir in the default script
  if [ -f "${JAVA_APP_DIR}/${run_env_sh}" ]; then
      source "${JAVA_APP_DIR}/${run_env_sh}"
  fi

  export JAVA_APP_DIR

  # JAVA_LIB_DIR defaults to JAVA_APP_DIR
  export JAVA_LIB_DIR="${JAVA_LIB_DIR:-${JAVA_APP_DIR}}"
  if [ -z "${JAVA_MAIN_CLASS}" ] && [ -z "${JAVA_APP_JAR}" ]; then
    JAVA_APP_JAR="$(auto_detect_jar_file ${JAVA_APP_DIR})"
    check_error "${JAVA_APP_JAR}"
  fi

  if [ "x${JAVA_APP_JAR}" != x ]; then
    local jar="$(get_jar_file ${JAVA_APP_JAR} ${JAVA_APP_DIR} ${JAVA_LIB_DIR})"
    check_error "${jar}"
    export JAVA_APP_JAR=${jar}
  else
    export JAVA_MAIN_CLASS
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

# Start JVM
startup() {
  # Initialize environment
  load_env

  local args
  cd ${JAVA_APP_DIR}
  if [ "x${JAVA_MAIN_CLASS}" != x ] ; then
     args="${JAVA_MAIN_CLASS}"
  else
     args="-jar ${JAVA_APP_JAR}"
  fi

  procname="${JAVA_APP_NAME-java}"

  log_info "exec -a \"${procname}\" java $(get_java_options) -cp \"$(get_classpath)\" ${args} $*"
  log_info "running in $PWD"
  exec -a "${procname}" java $(get_java_options) -cp "$(get_classpath)" ${args} $*
}

# =============================================================================
# Fire up
startup $*
