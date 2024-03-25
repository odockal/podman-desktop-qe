# Testing kubebernetes contexts page

## Prerequisities
1. Podman
2. Two of the resource binaries (kind, crc, minikube...), no clusters created

## Basic checks
1. Open Kubernetes Contexts page in Podman Desktop via Settings -> Kubernetes
2. Page should be empty with `No Kubernetes contexts found`
3. Go to Settings -> Resources, create one of these clusters:
    - Create Minikube cluster by clicking `Create New` in Minikube panel, naming the cluster minikube-cluster and clicking `Create` in the creation page
    - Create Kind cluster by clicking `Create New` in the Kind panel, name the cluster kind-cluster and clicking `Create` in the follow-up dialog
    - Create OpenShift Local cluster with Microshift preset - check in OpenShift Local settings page under `Preset`. Click `Create New` and `Create` on the creation page
4. Open Kubernetes Contexts page under Settings, card with newly created cluster should appear.
5. Check that created cluster is marked as default 
    - (no Set as Default Context button on the card)
6. Create another cluster as described in step 3
7. Open Kubernetes Contexts, check these fields:
    - Cluster name is identical both in header and in `CLUSTER` fields, it is the name set during cluster creation.
    - `SERVER` should appear, show sensible values
    - `USER` should be visible: cluster name for Kind and Mminikube
    - `NAMESPACE` should be visible for OpenShift and Minikube.
    - `Pods` and `Deployments` counters are both set to 0.

## Managing Clusters from Resources page
1. Create cluster as mentioned above
2. Go to Settings -> Kubernetes and check that Status of the contect is `Active`
3. Go to the Resources page and stop the cluster
4. Go back to Settings -> Kubernetes and check Status of the context is `Unreachable`

## Managing kubernetes context from status bar
1. Create cluster as mentioned above
2. Check that it is present at the status bar (bottom left) under `Current Kubernetes context`
3. Create another cluster, set it to be default on Settings -> Kubernetes page
4. Check that status bar reflects this change (`Current Kubernetes context` displays second context)
5. Click `Current Kubernetes context` and select the first created context as the default one
6. Check that default cluster under Settings -> Kubernetes page changed as well

## Deployment of containers, switching and deleting contexts
1. Pull `nginx` image, start a container and name it `nginx`
2. On the Containers page, select the drop down menu next to the container, click `Deploy to Kubernetes`.
3. Check that correct (default) context is chosen
    - name the pod `nginx-pod`
    - choose proper service exposure (route or ingress controller)
4. Click `Deploy` and wait for the `Done` button
5. Go to Settings -> Kubernetes, check that the Pods counter on default context went up by 1
6. Switch default context to another cluster by clicking `Set as Default Context button` on its card
7. Go through steps 1-6 again and verify it deploys the pod to the correct context
8. Delete cluster record from this page using `Delete Context`, check that it is deleted
9. Check that deployed container `nginx` is deleted from Containers page