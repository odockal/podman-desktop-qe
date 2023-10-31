# Compose testing scenario after Podman Desktop 1.5.0 - onboarding workflow

Aim is to verify that compose (docker/podman) tool can be installed using Podman Desktop onboarding workflow. Podman Desktop also must "see" these objects that `compose up` command spinned up. 

## Requirements
1. Podman installed
2. One could also have docker/podman compose binary tool downloaded and installed beforehand. Then it should not be offered by Podman Desktop to install the tool in Settings -> Resources -> Compose Resource -> Setup button. 

## Scenario

### Compose installation and Docker Compatibility

1. Start up podman desktop
2. Install Compose using Compose onboarding workflow: **Settings -> Resources -> Compose -> Setup**
* Compose Download page: Choose a docker-compose version to download (ie.: v2.23.0) -> Next
* `Note: Want to use docker CLI tools such as: docker compose up or docker-compose with podman? Enable Docker Compatibility within Preferences`
* Compose Downloaded successfully
    ```
    Compose has been successfully downloaded! In order for podman compose (podman CLI v4.7.0+) to work correctly, it is required for Compose to be installed system-wide for podman to access the binary.
    The next step will install Compose system-wide. You will be prompted for system privileges when enabling this.
    ```
* Next to install Compose system wide
* Compose Successfully Installed - Successfully installed system wide -> Next to finish the workflow
    ```
    How to use Compose
    Run podman compose up (podman CLI v4.7.0+) or docker-compose in a directory with a compose.yaml. Podman Desktop will automatically detect the Compose deployment and show it in the container list.'
    
    $ podman compose up
    ```
* In order to make the command `podman compose up` work with installed docker-compose cli tool, we need to enable Docker Compatibility - **Linux and Mac Only, Windows has Docker Compatibility mode enabled by default**
3. Enable Docker compatibility (Linux and Mac) -> Status Bar/Tool Bar item `Docker Compatibility`
    ```
    Do you want to enable Docker socket compatibility mode for Podman? Administrative privileges are required to enable or disable the systemd Podman socket for Docker compatibility. -> Enable 
    ```
* Insert credentials
    ```
    Do you want to create a symlink from /run/podman/podman.sock to /var/run/docker.sock to enable Docker compatibility without having to set the DOCKER_HOST environment variable?
    ```
* Enable -> `Symlink created successfully. The Podman socket is now available at /var/run/docker.sock.`
* `Podman systemd socket has been enabled for Docker compatibility.`

### Compose verification

1. Go to a cli and try: `docker-compose version`
2. Assert that `docker-compose` version is the one that was installed via Podman Desktop
3. Clone example compose application repository (`awesome-compose`) TODO: switch to podman desktop compose demo
4. Checkout into the compose app folder (`awesome-compose/flask-redis`)
5. Now we will test `podman compose up` command or `docker-compose` cli tool
6. Run `podman-compose up -d`
7. Verify that process has finished sucessfully - check logs
8. Return to Podman Desktop
9. Open Images and check that demo app image are present (ie. `redis`, `flask/web`)
10. Open Containers page and verify that `compose` labeled container(s) with name `flask-redis` is present and have two underlying containers: `web-1` and `redis-1` that are up and running
11. Enter details of `web-1` check logs, terminal, inspect
12. Enter details of `redis-1` check logs, terminal, inspect
13. Verify that `web-1` app is running and is accessible on `localhost:8000` - Counter is updated

### Podify and deploy to Kubernetes

1. Create a pod from a compose container - mark compose container and press "podify" button
2. Name it `compose-web-pod`
3. Verify that containers (compose) are stopped
4. New pod is spinned up and containers in are running
5. Application is available on the `localhost:8000`
6. Enter pod and choose to `Deploy To Kubernetes` option
7. Push image to ... (openshift/kubernetes, sandbox, kind)
8. Depending on the cluster type - choose particular service exposure (using route or ingress controller)
9. Verify that form with deployment is done sucessfully - open route, or enter web app on `localhost:9090`
10. Stop, delete, clean up.

## Resources

1. [Docker awesome compose](https://github.com/docker/awesome-compose)