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

setup_java_app_and_lib() {
  # Default the application dir to the S2I deployment dir
  if [ -z "$JAVA_APP_DIR" ]
    then JAVA_APP_DIR=/deployments
  fi

  # application-source provided shell script that may set environment
  # variables
  if [ -f "${JAVA_APP_DIR}/run-env.sh" ]; then
    source "${JAVA_APP_DIR}/run-env.sh"
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
