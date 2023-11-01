# Advanced suite to be tested in various scenarios (Redis + python frontend)

## Create a python frontend app with redis backend (official redis + demo frontend)

1. Pull `quay.io/centos7/redis-5-centos7`
2. Start a container named `redis`
3. Pull `quay.io/slemeur/python-app` or build an image from containerfile (`github.com/redhat-developer/podman-desktop-demo/primary-podify-demo/front/Dockerfile`)
4. Get `redis` container's internal IP address - Inspect and find "NetworkSettings.IPAddress" value, let's say `$redis.ip`
5. Start container from python-app
    * Name it `my-python-app:1.0`
    * Mapping port 5000 to local port 5000
    * Networking: Add extra host: `redis`: `$redis.ip`
6. Right now, application should be running on `localhost:5000` - counter for get requests

## Create a a demo application with demo backend and frontend

We will be using [podman-primary-demo](https://github.com/redhat-developer/podman-desktop-demo/blob/main/primary-podify-demo/README.md) example to verify multicontainer application execution

1. Either pull backend and front end images or build them locally
    * Building images locally from containerfiles: [backend](https://github.com/redhat-developer/podman-desktop-demo/blob/main/primary-podify-demo/backend/Dockerfile), [frontend](https://github.com/redhat-developer/podman-desktop-demo/blob/main/primary-podify-demo/front/Dockerfile)
    * Pull images: `quay.io/podman-desktop-demo/podify-demo-backend:v1` and `quay.io/podman-desktop-demo/podify-demo-frontend:v1`
2. Run the backend image - start a container named `backend` and provide a port mapping `6379:6379`
3. Get `backend` container's internal IP address - open `backend` container, go to Inspect tab and find "NetworkSettings.IPAddress" value, let's say `$redis.ip`
4. Run the frontend image - start a container named `frontend`
    * Name it `frontend-app`
    * Use mapping  of the container port 5000 to host port 5000
    * Networking tab: Add extra host: `redis`: `$redis.ip`
5. Right now, application should be running on `localhost:5000` - counter for get requests

## Podify the application

7. Create a pod from two running containers - ie. `frontend-app-pod`
8. Created pod should be running on the same address and port, counter is reset, containers are stopped

## Deploying to a Kubernetes cluster

### From a container or a pod to a Kubernetes

1. Choose container or pod (`frontend-app-pod`) you want to deploy to a kubernetes cluster
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


