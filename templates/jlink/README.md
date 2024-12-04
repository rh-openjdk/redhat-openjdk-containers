# OpenShift Jlink integration (Tech Preview)

To try it out,
you need:

1. Access to an OpenShift instance, such as [OpenShift Local](https://developers.redhat.com/products/openshift-local/overview)
2. UBI9 OpenJDK ImageStreams that include `jlink-dev` changes (see below)
3. The template [jlinked-app.yaml](jlinked-app.yaml).

## Stage 0: UBI9 OpenJDK ImageStreams with jlink-dev changes

Until the `jlink-dev` work is merged, prior to trying out the template, we must first
prepare UBI9 OpenJDK ImageStreams with `jlink-dev` support.

1. Build a suitable OpenJDK container image from [this
   repository](https://github.com/jboss-container-images/openjdk),
   branch `jlink-dev`. e.g.

        cekit --descriptor ubi9-openjdk-17.yaml build docker

2. Within your OpenShift project,

        oc create imagestream ubi9-openjdk-17

3. You may need to configure your container engine to not TLS-verify the OpenShift
   registry. For Docker, add the following to `/etc/docker/daemon.json` and restart
   the daemon:

        {
          "insecure-registries": [ "default-route-openshift-image-registry.apps-crc.testing" ]
        }

4. Log into the OpenShift registry, e.g.

        REGISTRY_AUTH_PREFERENCE=docker oc registry login

5. tag and push the dev image into it. The OpenShift console gives you the
   exact URI for your instance

        docker tag ubi9/openjdk-17:1.18 default-route-openshift-image-registry.apps-crc.testing/jlink1/ubi9-openjdk-17:1.18
        docker push default-route-openshift-image-registry.apps-crc.testing/jlink1/ubi9-openjdk-17:1.18

## Stage 1: Load the template into OpenShift and instantiate it

Create an OpenShift template `templates/jlink-app-template` from the jlinked-app template file

        oc create -f templates/jlink/jlinked-app.yaml 

Process it to create the needed objects. You can list the parameters using

        oc process --parameters jlink-app-template

Some suitable test values for the parameters are

 * JDK_VERSION: 17
 * APP_URI: https://github.com/jboss-container-images/openjdk-test-applications
 * REF: master
 * CONTEXT_DIR: quarkus-quickstarts/getting-started-3.9.2-uberjar
 * APPNAME: quarkus-quickstart

        oc process \
            -p JDK_VERSION=17 \
            -p APP_URI=https://github.com/jboss-container-images/openjdk-test-applications \
            -p REF=master \
            -p CONTEXT_DIR=quarkus-quickstarts/getting-started-3.9.2-uberjar \
            -p APPNAME=quarkus-quickstart \
            templates/jlink-app-template \
            | oc create -f -

## Stage 2: Observe the results

See all the OpenShift objects that were created:

        oc get all

## Stage 3: Kick off builds

There will be three BuildConfigs, called something like

1. jlink-builder-jdk-17
2. jlink-s2i-jdk-17
3. multistage-buildconfig

Start a build for (1). Once complete, builds for (2) and (3) should be
automatically triggered in sequence.

## Stage 4: create deployment

The ImageStreamTag `lightweight-image:latest` will be populated with the new
application container image.

Create a deployment to see it work. E.g., in the Developer Perspective, select
"+Add", "Container Images", "Image stream tag from internal registry", ...,
"Create"

Then from "Topology", select the "Open URL" icon to open the newly deployed
App.
