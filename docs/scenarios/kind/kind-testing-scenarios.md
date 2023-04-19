# Podman Desktop Kind integration setup and scenarios

## Topics
* [Aim](#aim)
* [Prerequisities](#prerequisities)
* [Basic scenario](#basic-scenario)
* [Podman Desktop Kind integration on multiple OSes](#podman-desktop-kind-integration)
* [Resources](#resources)

## Aim
As a developer, I would like to deploy and run an image locally on my kubernetes cluster created using kind so that I can access the running application in kubernetes cluster from my machine.

## Prerequisities
* `podman` - [download and install](https://podman.io/getting-started/installation#installing-on-linux)
* `kubectl` - [download and install](https://kubernetes.io/docs/tasks/tools/) (on PATH)

## Basic scenario
Install Kubernetes cluster using kind, deploy an application from image and access it from local machine. This is a summary of what we want to do in Podman Desktop. Let's do it manually first in order to show it is possible.

#### 1. Get and install `kind`
* `kind` - [download and install](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

#### 2. Prepare to be run as rootless
* On linux it is neccessary to adjust kind to be [run as rootless](https://kind.sigs.k8s.io/docs/user/rootless/):
    ```sh
    $ ./kind create cluster
    enabling experimental podman provider
    ERROR: failed to create cluster: running kind with rootless provider requires setting systemd property "Delegate=yes", see https://kind.sigs.k8s.io/docs/user/rootless/
    ```

    Option 1. Run with experimental flag on
    ```sh
    $ KIND_EXPERIMENTAL_PROVIDER=podman ./kind create cluster
    ```
    Option 2. Use systemd user's scope to run
    ```sh
    $ systemd-run --scope --user ./kind create cluster
    Running scope as unit: run-r365b1628c1ea4e4f8a16988d609cab4d.scop
    ...
    ```

#### 3. Creating a cluster
* In order to expose application running inside the kubernetes cluster to the outter world, we need to add port mapping. we need to route host's localhost on port 30000 into kind-control-plane container in kubernetes on port 30010 which will then let other containers inside to communicate with outside. When this setup is done, something like `curl http://localhost:30000` will reach the app running inside containers in kubernetes cluster (created by kind). Create a configuration yaml file, ie. `kind-local-port-mapping.yaml` with this content:
    ```yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      extraPortMappings:
      - containerPort: 30010
        hostPort: 30000
    ```
* We need to create a cluster first and pass our configuration into it:
    ```sh
    $ systemd-run --scope --user ./kind create cluster --config=kind-local-port-mapping.yaml
    Running scope as unit: run-r365b1628c1ea4e4f8a16988d609cab4d.scope
    enabling experimental podman provider
    Creating cluster "kind" ...
     ✓ Ensuring node image (kindest/node:v1.24.0) 🖼
     ✓ Preparing nodes 📦
     ✓ Writing configuration 📜
     ✓ Starting control-plane 🕹️
     ✓ Installing CNI 🔌
     ✓ Installing StorageClass 💾
    Set kubectl context to "kind-kind"
    You can now use your cluster with:
    kubectl cluster-info --context kind-kind
    Thanks for using kind! 😊
    ```
* receive basic info of the running cluster using `kubectl`
    ```sh
    [odockal@fedora kind]$ kubectl cluster-info --context kind-kind
    Kubernetes control plane is running at https://127.0.0.1:39951
    CoreDNS is running at https://127.0.0.1:39951/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
    ```

#### 4. Deploy an application to the cluster
* We need to create a deployment with an image that will server as our application, save it as `httpd-deployment.yaml`:
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: httpd-app
      name: httpd-app
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: httpd-app
      template:
        metadata:
          labels:
            app: httpd-add
        spec:
          containers:
          - image: httpd
            name: httpd
            ports:
            - containerPort: 80
    ```
* Apply the yaml to the cluster (deploy the application)
    ```sh
    $ kubectl apply -f httpd-deployment.yaml --context kind-kind
    deployment.apps/nginx-deployment created
    ```
* Check it is created on the cluster
    ```sh
    [odockal@fedora kind]$ kubectl get pods --context kind-kind
    NAME                         READY   STATUS    RESTARTS   AGE
    httpd-app-5ff8885fc5-6qvxx   1/1     Running   0          50m
    ```
    ```sh
    [odockal@fedora kind]$ kubectl get deployments --context kind-kind
    NAME        READY   UP-TO-DATE   AVAILABLE   AGE
    httpd-app   1/1     1            1           50m
    ```
#### 5. Expose the application running on the local cluster to the outter world
* Expose the application - resource (pod, deployments, etc.) as a new Kubernetes service
* Service that will configure communication between container with httpd and container with kind-control-plane could be like this (`httpd-service.yaml`):
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: httpd-add
    spec:
      selector:
        app: httpd-add
      type: NodePort
      ports:
        - port: 80
          nodePort: 30010
    ```
* Apply the yaml config:
    ```sh
    $ kubectl apply -f httpd-service.yaml --context kind-kind
    deployment.apps/nginx-deployment created
    ```
#### 6. Application availability verification
* Verify the setup and application on your host
    ```sh
    kubectl get services --context kind-kind
    NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
    httpd-app    NodePort    10.96.18.21   <none>        80:30010/TCP   51m
    kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP        52m
    ```
* Send a request to the app. into a cluster and check httpd logs running in the pod
    ```sh
    $ curl http://localhost:30000
    <html><body><h1>It works!</h1></body></html>
    ```
* Check the logs using `kubectl`
    ```sh
    $ kubectl logs httpd-app-5ff8885fc5-6qvxx
    AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.244.0.4. Set the 'ServerName' directive globally to suppress this message
    AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.244.0.4. Set the 'ServerName' directive globally to suppress this message
    [Mon Apr 17 16:48:43.637000 2023] [mpm_event:notice] [pid 1:tid 139941771693376] AH00489: Apache/2.4.57 (Unix) configured -- resuming normal operations
    [Mon Apr 17 16:48:43.637110 2023] [core:notice] [pid 1:tid 139941771693376] AH00094: Command line: 'httpd -D FOREGROUND'
    10.244.0.1 - - [17/Apr/2023:17:36:04 +0000] "GET / HTTP/1.1" 200 45
    10.244.0.1 - - [17/Apr/2023:17:43:06 +0000] "GET / HTTP/1.1" 200 45
    ```
#### 7. Summary
We were able to create a local kubernetes cluster using kind with specific configuration in order to expose containers running inside the cluster. Eventually we deployed the application and provided a way to expose the app in container using kubernetes service.

## Podman Desktop Kind integration

Let's see how can we make use of Podman Desktop to onboard kind worflows on multiple OSes.

We have two options here in order to make sure our kubernetes containers are available from our host:
1. Configure kubernetes control plane when creating cluster with kind: `kind create cluster --config=control.yaml`
    * we do not have that option to pass an yaml file into kind command in podman desktop (ToDo - fill issue)
2. Use provided option to use ingress controller via podman desktop, see https://github.com/containers/podman-desktop/pull/1980 (unverified)
    * Start kind cluster with enabled ingress controller
    * Deploy proper kubernetes manifest via Play Kubernetes Yaml, see below
    * Alternative using `kubectl`: `kubectl apply -f https://projectcontour.io/examples/httpbin.yaml`
    * Testing app should be available on `http://localhost:9090`
3. Other option are currently under development
* https://github.com/containers/podman-desktop/pull/2149

The beginning of the scenario differs depending on the OS, but at some point scenarios are the same

### Linux Kind integration on Podman Desktop
1. Have podman installed on your machine
2. Download, install and run Podman Desktop


### Windows Kind integration in Podman Desktop
1. Download and install Podman Desktop
2. Install podman
3. Choose to perform one of rootfull/rootless setups of podman machine
    *  initialize podman via podman desktop
    *  Choose one of approaches - rootfull or rootless, see below.

#### Using rootless podman provider on Windows
* wsl installed on the system with default version 2, we do not need to have distro installed (podman will do that)
* create `.wslconfig` file in your home with this content:
    ```sh
    [wsl2]
    kernelCommandLine = cgroup_no_v1=all
    ```
* Update wsl: `wsl --update`
* Initialize and start podman machine using podman desktop
* in powershell: `podman machine ssh`
* Run with `sudo`:
*   `mkdir /etc/systemd/system/user@.service.d/`
*   Insert this content into `/etc/systemd/system/user@.service.d/delegate.conf`
    ```sh
    [Service]
    Delegate=yes
    ```
* run `systemctl daemon-reload`
* Create `mkdir /etc/modules-load.d`
* Insert content into `iptables.conf`
    ```sh
    ip6_tables
    ip6table_nat
    ip_tables
    iptable_nat
    ```
* exit the machine
* You probably need to restart podman machine (using podman desktop)
* Now you should be able to create kubernetes cluster using kind with rootless podman machine

#### Using Rootfull podman machine on Windows
See [known issues](#known-issues).
* Set podman machine (`podman-machine-default`) to be rootful:
    * powershell: `podman machine set --rootful`
* Restart podman machine and try to create Kind cluster -> Now it should work


### Mac OS Kind integration in Podman Desktop
1. Install Podman Desktop using brew
* `brew install podman-desktop`
2. Run Podman Desktop and Install Podman
3. Initialize podman
4. ToDo - same steps as for windows?

### Scenario and verification steps - same for all platforms
1. Install Kind binary
2. Options to use integrated ingress controller - contour
* Option A, using integrated support for ingress controller using Controur project
    1. Start Cluster in Settings -> Resources with ingress controller enabled
* Option B, providing connectivity to the kubernetes cluster with our own means
    1. See `kind-local-port-mapping.yaml` kube. manifest and use cli to set it up.
    2. `kind create cluster --config=kind-local-port-mapping.yaml`
3. Check the presence of `kind-control-plane` container
4. Options how get an image and build an app.
* Option to deploy the app with pulling an image using podman desktop
    1. Pull an image (httpd)
    6. Start a container (httpd)
    7. Create a pod from container => Deploy to Kubernetes
    8. Check that pod is created
    9. Verify deployed podified application that is available on kubernetes cluster, should utilize kind provided port (9090)
    10. This scenario has (ToDo)
* Option to push an image to the kind cluster and creating a pod from YAML with expected image
    1. Pull an image (httpd)
    2. Push to kind
    3. Play kubernetes Yaml with proper content (ToDo)
* Option to create whole app and services using Play Kubernetes Yaml
    1.  define pods, services and ingress kubernetes objects in yaml(ToDo)
5. Verification


## Known issues
* When behind VPN, the network restriction can cause network or some services inaccessibility in containers, could results in container errors like `ErrImagePull` or `ImagePullBackOff`, to debug use `kubectl desribe pod <pod-name>`, resources: [Kubernetes ImagePullBackOff error](https://www.tutorialworks.com/kubernetes-imagepullbackoff/)
* When on Windows, there seems to be a problem for Kind cluster discovery in Podman Desktop. It happens when podman engine is using a machine with root priviledges (a connection with root user):
    * Start Podman desktop
    * Set default podman system coonection the one with root use access (`podman system connection ls`, `podman system connection default podman-machine-default-root`)
    * Restart podman engine (machine) if needed via Settings -> Resources
    * Try to create new Kind cluster -> It should succeed but the [kind cluster will not be visible in Resources](https://github.com/containers/podman-desktop/issues/2080)
    * Possible workaround could be to instead choosing root connection, one can set actual podman machine (`podman-machine-default`) to be rootful: `podman machine set --rootful`
    * Restart podman machine and try to create Kind cluster -> Now it should work
## Resources
* [Kind docs](https://kind.sigs.k8s.io/docs/user/quick-start/)
* [Super easy kind+kubernetes deployment+service with port mappings](https://kind.sigs.k8s.io/docs/user/using-wsl2/#accessing-a-kubernetes-service-running-in-wsl2)
* [Run your local Kubernetes cluster with Kind](https://www.upnxtblog.com/index.php/2020/04/09/run-your-local-kubernetes-clusters-with-kind/)
* ALternatives to using a `kind` for application deployment [Minikube vs. Kind vs. k3s](https://shipit.dev/posts/minikube-vs-kind-vs-k3s.html)
* [Running kind with rootless podman does not work as documented](https://github.com/kubernetes-sigs/kind/issues/2872)
* [Creating Kubernetes cluster for development with Kind](https://faun.pub/creating-a-kubernetes-cluster-for-development-with-kind-189df2cb0792)

