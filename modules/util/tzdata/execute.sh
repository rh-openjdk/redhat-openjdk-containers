#!/bin/bash
set -euo pipefail

for candidate in yum dnf microdnf; do
    if command -v "$candidate"; then
        mgr="$(command -v "$candidate")"

        # remove and install instead of reinstall, which can fail if the
        # installed NVR is not available in the configured package repositories
        rpm --nodeps --erase tzdata
        "$mgr" -y install tzdata
        "$mgr" -y clean all
        exit
    fi
done

echo "cannot find a package manager" >&2
exit 1
