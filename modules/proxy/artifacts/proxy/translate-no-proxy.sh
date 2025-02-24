# Translates no_proxy environment variables into a format consumable
# by Java
#
# Output is transferred through the following environment variables:
#   * JAVA_PROXY_NONPROXYHOSTS: list of no-proxy hosts formatted for Java
#
# Example usage:
#   source "$JAVA_PROXY_MODULE"/translate-no-proxy.sh
#   if [ -n "$JAVA_PROXY_NONPROXYHOSTS" ]; then
#     # use JAVA_PROXY_NONPROXYHOSTS
#   fi
#

local JAVA_PROXY_NONPROXYHOSTS=

local noProxy="${no_proxy}"
if [ -n "$noProxy" ]; then
    noProxy="${noProxy//,/|}"
    noProxy="${noProxy//|./|*.}"
    noProxy="${noProxy/#./*.}"
    JAVA_PROXY_NONPROXYHOSTS="${noProxy}"
fi
