# Parses proxy URL into components which may be used independently.
#
# Input:
#   1: Proxy URL.  If unset will search the following environment variables for
#        a default value: https_proxy, http_proxy
#   2: Default scheme.  If a scheme is not specified in the URL, this will be
#        returned.
#   3: Default port.  If a port is not specified in the URL, this will be
#        returned.
#
# Output is transferred through the following environment variables:
#   * JAVA_PROXY_SCHEME: scheme of proxy URL
#   * JAVA_PROXY_USERNAME: proxy user
#   * JAVA_PROXY_PASSWORD: proxy password
#   * JAVA_PROXY_HOST: proxy host
#   * JAVA_PROXY_PORT: proxy port
#
# Example usage:
#   source "$JAVA_PROXY_MODULE"/parse-proxy-url.sh "http://user@myproxy.com/" "http" "80"
#   if [ -n "$JAVA_PROXY_HOST" ]; then
#     # use JAVA_PROXY_ vars
#   fi
#

local JAVA_PROXY_SCHEME=
local JAVA_PROXY_USERNAME=
local JAVA_PROXY_PASSWORD=
local JAVA_PROXY_HOST=
local JAVA_PROXY_PORT=

local url="${1:-${https_proxy:-${http_proxy}}}"
local default_scheme="$2"
local default_port="$3"

if [ -n "$url" ] ; then
  #[scheme://][user[:password]@]host[:port][/path][?params]
  eval $(echo "$1" | sed -e "s+^\(\([^:]*\)://\)\?\(\([^:@]*\)\(:\([^@]*\)\)\?@\)\?\([^:/?]*\)\(:\([^/?]*\)\)\?.*$+JAVA_PROXY_SCHEME='\2' JAVA_PROXY_USERNAME='\4' JAVA_PROXY_PASSWORD='\6' JAVA_PROXY_HOST='\7' JAVA_PROXY_PORT='\9'+")

  JAVA_PROXY_SCHEME="${JAVA_PROXY_SCHEME:-$default_scheme}"
  JAVA_PROXY_PORT="${JAVA_PROXY_PORT:-$default_port}"
fi

