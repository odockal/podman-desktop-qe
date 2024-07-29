# Basic suite to be tested in various scenarios

## Get an image
You can use some of the images available through [images scenario](https://github.com/odockal/podman-desktop-qe/blob/main/docs/scenarios/suites/images.md#example-images-for-various-purposes).

### Start the container and test podify workflow (nginx, httpd)

1. Start the container from an image - keep port 80:9000 (`nginx`) for port mapping (8080:8080 for `httpd`)
2. Check container is running, `localhost:9000 (8080)`, log shows right output, terminal is available, kube is present, open in browser.
3. Mark container and create a pod
4. Check pod is running, container used for podifitcation is stopped, there is new containers group with label `pod` present 
5. The app is available on `localhost:9000 (8080)` or through `Open in browser` button, summary, logs, inspect, kube all show correct information
6. Stop the pod, restart the pod
7. Delete the pod - pod and its containers are deleted

### From a container or a pod to a Kubernetes

1. Toggle container or pod you want to deploy to a kubernetes cluster
2. Select one of the contexts
    * kind
    * dev sandbox
    * openshift
    * microshift
    * minikube
3. Open the container / pod and click `Deploy to Kubernetes` 
(in the drop down menu on the pods page or as a button on the details page)
4. Specify pod name
5. `Use Kubernetes services`
6. Expose the application port to the outter world (local machine)
    * Kind: `Create an ingress controller`
    * OpenShift/Dev Sandbox: `Create OpenShift routes`
7. Deployment is successfull - verify that pod is running, it has proper label (`Podman` vs. `Kubernetes`)
8. Application is accessible on specified locahost port or URL (route)
9. Stop and delete the pod

### Play Kubernetes YAML with Podman engine or onto Kubernetes cluster

1. Create a kubernetes file (yaml) or use any existing [kubernetes manifest](https://github.com/odockal/podman-desktop-qe/tree/main/examples/manifests)
2. Pull `httpd` image, start container and go to the `kube` tab, or call `generate kube` 
3. Delete the container
4. Create a file with this content (`httpd-pod.yaml`) 
5. Go to the Pods page and press `Play Kubernetes YAML`
6. Choose yaml file
7. Pick up runtime (`Using a Podman container engine`, `Using a Kubernetes cluster`)
8. Verify it is deployed:
    * Podman engine shows Done button and pods basic info (ids)
    * Kuberetes cluster shows nothing
9. Verify that pod was created and is running and has right label (if there are more pods)
10. Stop the pod and delete it



