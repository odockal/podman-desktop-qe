# Testing scenarios using OpenShift Local

## Prerequisities
1. Podman installed
2. Download, install CRC binary and put it on the PATH (Linux)

## Instalation and starting up of OpenShift local extension

1. Open Podman Desktop Settings -> Extensions
2. Install a new extension from OCI Image -> `ghcr.io/crc-org/crc-extension:latest` or `quay.io/redhat-developer/openshift-local-extension:latest`
    * Or install the extension from the Settings -> Extensions or from the dashboard
    * requires podman to be running as it pulls the image from container registry
    * Starting 1.0.0 podman is not required to install extensions
3. Verify that OpenShift Local extension is present in Dashboard and under Settings -> Resources
4. Go to the Dashboard, check that OpenShift Local extension is present, you can try to run the detection check
5. Install CRC on you Windows/(Mac) by using Install button
6. First it downloads the installer (named something like 123sd456.msi) which is the run using windows msi wizard
7. Finish the installation the you will be asked what preset you want to use (OpenShift or Microshift)
8. If you choose openshift, it will download a crc bundle (around 3 GB)
9. Once it is ready, you will need to restart the machine since it also allowed HyperV features
10. Restart the machine
11. After restart you should be able to see and run `initialize and start` or `start` option under OpenShift Local
12. Setup OpenShift Local configuration in Settings -> Preferences:
    * Pull secret file (https://console.redhat.com/openshift/create/local)
    * There should be option to choose crc binary if not present on the path (https://github.com/crc-org/crc-extension/issues/5)
    * Choose one of the present you want to use (openshift or microshift)
    * Configure proper resources for the particular preset (https://crc.dev/crc/#minimum-system-requirements_gsg)
13. Initialize and start the OpenShift Local instance
13. Wait for the `crc` to get into running state
14. Check kube context from System tray icon (`crc-admin`, `crc-developer` or `microshift`)



## Using OpenShift Local Openshift Preset and deploying an Nginx application

General guide for simple app. deployment to verify extension's functionality can be found [here](https://github.com/odockal/podman-desktop-qe/docs/scenarios/suites/)

We want to deploy an application (`nginx`) to our local openshift. We will use OpenShift local openshift preset, which will create a openshift local cluster that we can use.

1. Start OpenShift local with `openshift` preset, requires 9GB of Memory, 4 CPUs and around 31 GB of disc space.
2. Start the OpenShift local provider (takes quite a time)
3. Choose `crc-admin` kube context once the cluster is up on podman desktop system tray
4. Pull nginx image
5. Start a container from the image
6. Verify that container is running (containers page and localhost:9000)
7. Stop the container
8. Deploy container to kubernetes (Make sure that you picked up `crc-admin` context)
9. Make sure to toggle `Use kubernetes services` and `Create Openshift routes` and deploy the pod
10. Verify that pod was sucessfully created (`Pod is Running`) and is reachable via the link provided on `Deploy generated pod to Kubernetes`
11. Stop and Delete the pod

## Resources
* [CRC getting started guide](https://crc.dev/crc/#introducing_gsg)
* [CRC Extension repository](https://github.com/crc-org/crc-extension)