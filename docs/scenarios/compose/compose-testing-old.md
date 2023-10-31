# Compose testing scenario before Podman Desktop 1.5.0

Aim is to verify that compose (docker/podman) tool can be installed using Podman Desktop. Podman Desktop also must "see" these objects that `compose up` command spinned up. 

## Requirements
1. Podman installed
2. One could also have docker/podman compose binary tool downloaded beforehand. Then it should not be offered by Podman Desktop to install the tool.

## Scenario

### Compose verification

1. Start up podman desktop
2. Install Compose using tool bar item (Compose) -> choose one version (v2.18.0)
3. Choose to install it either locally or system wide (requires administrator priviledges)
4. Ok on the info dialog
5. Go to a cli a see `docker-compose version`
    * Assert that version is the one that PD installed
    * Checkout into the compose app folder (`awesome-compose/flask`)
    * Run `docker-compose up -d` (or `podman-compose`)
    * Verify that process has finished sucessfully 
    * Return to podman Desktop
6. Open Images and check that `buildkit` image is present
7. Open Containers page and verify that `compose` labeled container is present and running with name `flask`, consists of `web-1` container, also `buildkit` container is up and running
8. Insert into Details of `web-1`m check logs, terminal, inspect
9. Verify that `flask` app is running on `localhost:8000` (Hello World!)

### Podify and deploy to Kubernetes

1. Create a pod from a compose container - mark compose container and press "podify" button
2. Name it `compose-flask-pod`
3. Verify that containers (compose) are stopped
4. New pod is spinned up and containers in are running
5. Application is available on the `localhost:8000`
6. Enter pod and choose to `Deploy To Kubernetes` option
7. Push image to ... (openshift/kubernetes, sandbox, kind)S
8. Depending on the cluster type - choose particular service exposure (using route or ingress controller)
9. Verify that form with deployment is done sucessfully - open route, or enter web app on `localhost:9090`
10. Stop, delete, clean up.

## Known issues

1. `flask-redis` component
* OCI persmission denied. (rootless? crun?)
```sh
[+] Running 1/2
 ✔ Container flask-redis-redis-1  Start...                                 0.3s 
 ⠿ Container flask-redis-web-1    Startin...                               0.9s 
Error response from daemon: crun: open executable: Permission denied: OCI permission denied
```
* `python3: can't open file '/code/app.py': [Errno 13] Permission denied`

## Resources

1. [Docker awesome compose](https://github.com/docker/awesome-compose)