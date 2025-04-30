# Testing scenarios for OpenShift Image Checker

## Prerequisites

* Podman running

* Test image: `docker.io/library/httpd` 

* OCI Image: `ghcr.io/redhat-developer/podman-desktop-image-checker-openshift-ext:latest`


## Red Hat OpenShift Image Checker extension instalation

1. Open **Extensions**
    
    * Remove old version of the extension if present

2. Install the extension from OCI Image: `ghcr.io/redhat-developer/podman-desktop-image-checker-openshift-ext:latest`

    * `Red Hat OpenShift Image Checker` extension card is present in extension list
    * Extension status is `ACTIVE`, no errors are shown

3. Alternatively install from **Extensions -> Catalog**


## Red Hat Image Checker extension functionality

1. Pull image `ghcr.io/linuxcontainers/alpine`, verify:

    * **Check** tab is present on image details page

2. Open the **Check** tab, verify:

    * `Analysis Status` text is visible
    * `Providers` table is visible
    * `Analysis Results` table is visible
    * `Red Hat OpenShift Checker` is listed in providers table

4. Detection checks for these directives and commands are present in analysis table

    * `RUN` directive (chmod, chown, sudo/su)
    * `EXPOSE` directive
    * `USER` directive
    
5. Turn the `Red Hat OpenShift Checker` off
    
    * `Analysis Results` table is not present

6. Turn the `Red Hat OpenShift Checker` on
    
    * `Analysis Results` table is visible


## Red Hat Image Checker basic extension handling

1. Go to **Extensions**, disable `Red Hat OpenShift Checker`

    * Extension status is `DISABLED`
    * **Check** tab is not present on image details page

2. Re-enable `Red Hat OpenShift Checker`

    * Extension status is `ENABLED`
    * **Check** tab is visible on image details page

3. Remove extension

    * Extension card is not present in **Extensions**
    * **Check** tab is not present on image details page
