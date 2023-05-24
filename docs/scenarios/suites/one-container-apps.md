# Basic suite to be tested in various scenarios

## Pull image from unauthenticated source

### NGINX

1. Pull an image: `docker.io/library/nginx:latest`

### HTTPD

1. Pull an image: `quay.io/centos7/httpd-24-centos7:latest`

## Pull image from authenticated source

### UBI8/HTTPD-24
1. You need to login to the registry from where you want to pull authenticated image
2. Add new `registry.redhat.io` and login
3. Pull an image: `registry.redhat.io/ubi8/httpd-24` 
* Unauthenticated version can be obtained here: `registry.access.redhat.com/ubi8/httpd-24`

## Build an image from containerfile

1. Create containerfile with the content:
```sh
FROM quay.io/centos7/httpd-24/centos7
```
2. Build an image from containerfile, name it, ie. `httpd-local`

### Start the container and podify workflow

1. Start the container from an image - keep port 80:9000 mapping (8080:8080)
2. Check container is running, `localhost:9000 (8080)`, log shows right output, terminal is available, kube is present, open in browser.
3. Mark container and create a pod
4. Check Pod is running, former container is stopped, there is new containers group with label `pod` present 
5. The app. is available on `localhost:9000 (8080)`, inspect, kube, summary also show correct information
6. Stop the pod, restart the pod
7. Delete the pod - pod is gone and so are containers

### From a container or a pod to a Kubernetes

1. Choose container or pod you want to deploy to a kubernetes cluster
2. Choose a right context 
    * kind
    * dev sandbox
    * openshift
    * microshift
3. Open container or pod and Deploy generated pod to Kubernetes
4. Specify pod name
5. `Use Kubernetes services`
6. Expose the application port to the outter world (local machine)
    * Kind: `Create an ingress controller`
    * OpenShift/Dev Sandbox: `Create OpenShift routes`
7. Deployment is successfull - verify that pod is running, it has proper label (`Podman` vs. `Kubernetes`)
8. Application is accessible on specified locahost port or URL (route)
9. Stop and delete the pod

### Play Kubernetes YAML with Podman engine or onto Kubernetes cluster

1. Create a kubernetes file (yaml)
2. Pull `httpd` image, start container and go to the `kube` tab, or call `generate kube`
3. Create a file with this content (`httpd-pod.yaml`)
4. go to the Containers and press `Play Kubernetes YAML`
5. Choose yaml file
6. Pick up runtime (`Podman`, `Using Kubernetes cluster`)
7. Verify it is deployed:
    * Podman engine shows Done button and pods basic info (ids)
    * Kuberetes cluster shows nothing
8. Verify that pod was created and is running and has right label (if there are more pods)
9. Stop the pod and delete it



