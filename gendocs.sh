#!/bin/bash
set -euo pipefail

# This script arranges to call gendocs.py for each image descriptor we
# wish to generate documentation for, by switching to the relevant git
# branches and tags and enumerating the image descriptors.
# It is expected that this script is invoked via GitHub Actions.
#
# Usage: ./gendocs.sh

engine=${engine-podman}

die()
{
    echo "$@"
    exit 1
}

addToIndex()
{
    echo -e "$@" >> "$workdir/README.adoc"
}

# generate docs for a single image
genImageDocs()
{
    ref="$1"   # e.g. ubi8
    input="$2" # e.g. ubi8-openjdk-11.yaml

    name="$(awk '-F"' '/name: &name/ { print $2 }' "$input")"
    output="docs/$ref/${input/yaml/adoc}"

    mkdir -p "$(dirname "$output")"
    cekit --descriptor "$input" build --dry-run "$engine"
    python3 "$workdir/gendocs.py" "$name" > "$output"
    asciidoctor "$output"

    addToIndex "* link:$ref/${name/\//-}.html[$name]"
}

# moves to the git ref, enumerates all images, calls
# genImageDocs for each
handleRef()
{
    ref="$1"
    git checkout "$ref"
    for y in ubi?-*yaml; do
        genImageDocs "$ref" "$y"
    done
}

##############################################################################

for dep in cekit python3 asciidoctor; do
    if ! which "$dep" >/dev/null; then
        die "$dep is required to execute this script"
    fi
done

# This ensures the directory won't be purged when we switch refs
mkdir -p docs
touch docs/index.html

# backup files from this ref we need prior to switching git refs
# (we don't bother with cleaning up workdir, GHA will do that for us)
workdir="$(mktemp -td gendocs.XXXXXX)"
cp ./gendocs.py "$workdir/gendocs.py"
cp ./docs/README.adoc "$workdir/README.adoc"

for ubi in ubi9 ubi8; do
    UBI=${ubi^^}
    addToIndex "\n== $UBI\n"
    addToIndex "\n=== development\n"
    handleRef "$ubi"
    for tag in $(git tag -l "${ubi}-openjdk-containers*" | sort -r); do
        version=${tag/${ubi}-openjdk-containers-/}
        addToIndex "\n=== $version\n"
        handleRef "$tag"
    done
done

asciidoctor "$workdir/README.adoc" -o docs/index.html
