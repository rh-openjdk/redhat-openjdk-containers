jlink_techpreview_warning()
{
  {
    echo "WARNING WARNING WARNING"
    echo "        Jlink integration is a Tech Preview feature!"
    echo "        See <https://access.redhat.com/support/offerings/techpreview/>"
    echo "        for more information."
    echo "WARNING WARNING WARNING"
  } >&2
}

jlink_preflight_check()
{
    # preflight check: do we have what we need?
    if [ "$JAVA_VERSION" -lt 11 ]; then
      echo "Jlink integration not available for JDK${JAVA_VERSION}!"
      echo "Jlink integration is only supported for JDK versions 11 and newer."
      exit 1
    fi
    if [ ! -d /usr/lib/jvm/java/jmods ]; then
      echo "Jlink integration requires the jmods RPM to be installed in the builder image, e.g."
      echo "        microdnf install -y java-${JAVA_VERSION}-openjdk-jmods"
      exit 1
    fi
}
