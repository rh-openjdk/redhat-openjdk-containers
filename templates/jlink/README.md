# OpenShift Jlink integration (Tech Preview)

To try it out,
you need:

1. Access to an OpenShift instance, such as [OpenShift Local](https://developers.redhat.com/products/openshift-local/overview)
2. UBI9 OpenJDK ImageStreams that include `jlink-dev` changes (see below)
3. The template [jlinked-app.yaml](jlinked-app.yaml).

DISCLAIMER: This template requires OpenShift to be able to resolve ImageStreams, as such it can only be used in projects where the openshift.io/run-level label set to 0 or 1. This means it cannot be used with default, kube-public, kube-system, openshift, openshift-infra, openshift-node, and other system-created projects.

## Stage 0: UBI9 OpenJDK ImageStreams with jlink-dev changes

Whilst the `jlink-dev` feature is in Tech Preview, we must prepare separate
UBI9 OpenJDK ImageStreams with `jlink-dev` support.

1. Pull the Tech-Preview image

       podman pull registry.access.redhat.com/openjdk-tech-preview/openjdk-21-jlink-rhel9:latest
       podman tag  registry.access.redhat.com/openjdk-tech-preview/openjdk-21-jlink-rhel9:latest \
           openjdk-tech-preview/openjdk-21-jlink-rhel9:latest
        
OR

1. Build a suitable OpenJDK container image from [this
   repository](https://github.com/jboss-container-images/openjdk),
   branch `jlink-dev`. e.g.

        cekit --descriptor ubi9-openjdk-21.yaml build podman

2. Create an OpenShift project

        oc new-project $PROJECT

3. Within your OpenShift project,

        oc create imagestream openjdk-21-jlink-tech-preview

4. You may need to configure your container engine to not TLS-verify the OpenShift
   registry. For Docker, add the following to `/etc/docker/daemon.json` and restart
   the daemon:

        {
          "insecure-registries": [ "default-route-openshift-image-registry.apps-crc.testing" ]
        }

   For podman, add the following to `~/.config/containers/registries.conf`:

        [[registry]]
        location = "default-route-openshift-image-registry.apps-crc.testing"
        insecure = true

5. Log into the OpenShift registry, e.g.

        REGISTRY_AUTH_PREFERENCE=docker oc registry login

   or

        oc registry login

6. tag and push the dev image into it. The OpenShift console gives you the
   exact URI for your instance

        podman tag openjdk-tech-preview/openjdk-21-jlink-rhel9:latest default-route-openshift-image-registry.apps-crc.testing/$PROJECT/openjdk-21-jlink-tech-preview:latest
        podman push default-route-openshift-image-registry.apps-crc.testing/$PROJECT/openjdk-21-jlink-tech-preview:latest

## Stage 1: Load the template into OpenShift and instantiate it

Create an OpenShift template `templates/jlink-app-template` from the jlinked-app template file

        oc create -f templates/jlink/jlinked-app.yaml 

Process it to create the needed objects. You can list the parameters using

        oc process --parameters jlink-app-template

Some suitable test values for the parameters are

 * JDK_VERSION: 21
 * APP_URI: https://github.com/rh-openjdk/openjdk-container-test-applications
 * REF: master
 * CONTEXT_DIR: quarkus-quickstarts/getting-started-3.21.2-uberjar
 * APPNAME: quarkus-quickstart
 * TARGET_PORT: 8080
 * SERVICE_PORT: 8080

        oc process \
            -p JDK_VERSION=21 \
            -p APP_URI=https://github.com/rh-openjdk/openjdk-container-test-applications \
            -p REF=master \
            -p CONTEXT_DIR=quarkus-quickstarts/getting-started-3.21.2-uberjar \
            -p APPNAME=quarkus-quickstart \
            -p TARGET_PORT=8080 \
            -p SERVICE_PORT=8080 \
            templates/jlink-app-template \
            | oc create -f -

## Stage 2: Observe the results

See all the OpenShift objects that were created:

        oc get all

## Stage 3: Kick off builds

Instantiating the template will cause 3 separate BuildConfigs to be created and will automatically start their builds in sequence:

1. $APPNAME-jlink-builder-jdk-$JDK_VERSION
2. $APPNAME-jlink-s2i-jdk-$JDK_VERSION
3. $APPNAME-multistage-buildconfig

Where $APPNAME and $JDK_VERSION are the paremeters initially passed to the template.

A build will automatically start for (1). Once complete, builds for (2) and (3) should be automatically triggered in sequence.

## Stage 4: create deployment

The ImageStreamTag `$APPNAME-lightweight-image:latest` will be populated with the new application container image.

Create a deployment to see it work. E.g., in the Developer Perspective, select
"+Add", "Container Images", "Image stream tag from internal registry", ...,
"Create"

Then from "Topology", select the "Open URL" icon to open the newly deployed
App.
