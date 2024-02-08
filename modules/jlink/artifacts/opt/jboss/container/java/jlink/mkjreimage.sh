#!/bin/bash
# TODO: Still Needed?
set -euo pipefail

depsfile="module-deps.txt"

function generate_jre_image() {
	test -f $depsfile
	modules="$(cat $depsfile)"

	$JAVA_HOME/bin/jlink --output "$S2I_JLINK_OUTPUT_PATH" \
    	   	--add-modules "$modules" \
		--strip-debug --no-header-files --no-man-pages \
		--compress=2

	# Workaround for JDK11 jlinked-image inflating in size
	# https://bugzilla.redhat.com/show_bug.cgi?id=1652177
	# https://bugzilla.redhat.com/attachment.cgi?id=1508295
	if [ $JAVA_VERSION -eq 11 ]; then
		echo -n "Replacing shared libraries from JDK image '$S2I_JLINK_OUTPUT_PATH' with shared libraries from '$JAVA_HOME'... "

		pushd $S2I_JLINK_OUTPUT_PATH > /dev/null
		  for l in $(find -name \*.so); do
		    rm $l
		    cp $JAVA_HOME/$l $l
		  done
		popd > /dev/null
		echo "Done."
	fi
}
