# Testing scenarios using Red Hat OpenShift Sandbox

## Prerequisities
1. Podman

## Instalation and start up of Red Hat OpenShift Sandbox extension

1. Open Podman Desktop Settings -> Extensions
2. Install a new extension from OCI Image -> `ghcr.io/redhat-developer/podman-desktop-sandbox-ext:latest`
    * requires podman to be running as it pulls the image from container registry
3. Verify that Red Hat OpenShift Sandbox extension is present in Dashboard and under Settings -> Resources
4. Create new sandbox instance (Settings -> Resources -> Developer Sandbox -> Create new)
5. Login to the sandbox account and copy login command (as advised)
6. Set context name, ie. `my-sandbox`
7. Paste login command
8. Create sandbox
9. Check kube context from System tray icon (`my-sandbox`)

## Using Red Hat OpenShift Sandbox and deploying an Nginx application

We want to deploy an application (`nginx`) to our Red Hat OpenShift Sandbox.

1. Switch to the sandbox context you have set for you Sandbox instance
2. Pull an `nginx` image
3. Start a container from `nginx` image
4. Verify it is running (localhost:9000)
5. Stop the container
6. Deploy container to the kubernetes, select to `Create Openshift route` and `Use kubernetes services`, context: `my-sandbox`
7. Assert: Pod is deployed (`pod is running`) and the app is available through the link provided in `Deploy generated pod to Kubernetes` page (link by the pod creation status)
8. Stop/Delete the pod

## Resources
* [RH OpenShift sandbox repo](https://github.com/redhat-developer/podman-desktop-sandbox-ext)