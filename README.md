These are the Red Hat Universal Base Image (UBI) OpenJDK container images,
suitable for use with OpenShift Container Platform.

→ [API Docs](https://rh-openjdk.github.io/redhat-openjdk-containers/)

# Acquiring the Images

## From [Red Hat Container Catalog](https://catalog.redhat.com/en):

_Make sure you are viewing the most recent tag for each container_.

* [ubi10/openjdk-25](https://catalog.redhat.com/software/containers/ubi10/openjdk-25/690ca440f43a9c6b120b2970?image=6a1789a7b0f39e62fd2fe614)
* [ubi10/openjdk-21](https://catalog.redhat.com/software/containers/ubi10/openjdk-21/690ca3318f730aed0b1497fd?image=6a1789a84539c58e9ccddc58)
* [ubi10/openjdk-25-runtime](https://catalog.redhat.com/software/containers/ubi10/openjdk-25-runtime/690ca3e4c827022925ed2db5?image=6a1789a2c84ec7f9491c341a)
* [ubi10/openjdk-21-runtime](https://catalog.redhat.com/software/containers/ubi10/openjdk-21-runtime/690ca3b700d71ac7397b98c6?image=6a1789a4e30e09c84ec6c7e7)

The UBI10-based OpenJDK images are available under the terms of the [UBI
EULA](https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI).

[Red Hat provide Product documentation for
customers](https://access.redhat.com/documentation/en-us/openjdk/25).
Tables of environment variables used for image configuration are
published to <https://rh-openjdk.github.io/redhat-openjdk-containers/>.
These tables are automatically updated for every tagged release, and
every commit to the development branches.

Sources for older RHEL-based images are in the `ubi9`, `ubi8` and
`rhel7`
branches respectively.

# How to build the images

You need to [install
Cekit](https://docs.cekit.io/en/latest/handbook/installation/index.html)
to build these images.

These sources are prepared and tested for CeKit 4.16.0.

Example invocation to build `ubi10/openjdk-25` (substitute the image
YAML for other versions):

    cekit --descriptor ubi10-openjdk-25.yaml build podman

This will produce an image named `ubi10/openjdk-25`.

# Contributing

We welcome contributions! For patches, a Developer Certificate of Origin
(DCO) is required. See [CONTRIBUTING.md](CONTRIBUTING.md).

# License

© 2026 Red Hat, Inc. Distributed under the terms of the Apache License,
Version 2.0. See [LICENSE](LICENSE) file.
