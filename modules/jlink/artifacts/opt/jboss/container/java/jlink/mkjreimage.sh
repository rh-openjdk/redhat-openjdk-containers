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
}
