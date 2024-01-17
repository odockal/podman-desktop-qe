# Testing scenarios using Minikube

## Prerequisities
1. Podman installed

## Instalation and start up of Red Hat Minikube extension

1. Open Podman Desktop Settings -> Extensions
2. Install extension from OCI Image -> `ghcr.io/containers/podman-desktop-extension-minikube` or from Settings -> Extensions or Dashboard
3. Verify that Minikube extension is present in Dashboard
4. Install the Minikube CLI by clicking on Minikube in status bar and following the prompt.
5. Verify that Minikube binary was installed -> Minikube doesn't show in status bar anymore and there's Minikube tile in Settings -> Resources.
6. Create new Minikube instance (Settings -> Resources -> Minikube -> Create new)
    * Podman rootful machine required
    * Use default settings
7. Verify the cluster is running in Resources and there's Minikube option in the context tray.

## Using Minikube and deploying an Nginx application

General guide for simple app. deployment to verify extension's functionality can be found [here](https://github.com/odockal/podman-desktop-qe/docs/scenarios/suites/)

We want to deploy an application (`nginx`) to the Minikube instance.

1. Switch to Minikube context you have set for the Minikube instance
2. Pull an `nginx` image
3. Push the image to Minikube cluster
4. Start a container from the image
5. Verify it's running (localhost:9000)
6. Stop the container
7. Deploy container to the Kubernetes, keep default settings
7. Verify the pod is deployed (`Running`), click `Done` and verify the pod is also running in Pods
8. Stop/Delete the pod

## Resources
* [RH OpenShift sandbox repo](https://github.com/kubernetes/minikube)
* [Podman Desktop Documentation](https://podman-desktop.io/docs/minikube)