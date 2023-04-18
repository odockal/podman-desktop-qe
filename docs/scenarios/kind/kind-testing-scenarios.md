# Podman Desktop Kind integration on Linux

## Topics

* [Prerequisities](#prerequisities)
* [Resources](#resources)

## Prerequisities
* `podman` - [download and install](https://podman.io/getting-started/installation#installing-on-linux)
* `kubectl` - [download and install](https://kubernetes.io/docs/tasks/tools/) (put on path)

## Manual Kind installation and quick start
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

## Podman Desktop Kind integration (the same aim, different path)
We have two options here, make sure deployed container on kubernetes cluster is available from outside (Manual scenario) or to use Kind cluster creation option (Ingress node with use of project contour), see https://github.com/containers/podman-desktop/pull/1980.
* Start kind cluster with setting up ingress controller
* Deploy proper kubernetes manifest via Play Kubernetes Yaml, see below
* Alternative using `kubectl`: `kubectl apply -f https://projectcontour.io/examples/httpbin.yaml`
* Testing app should be available on `http://localhost:9090` - needs to be verified

### Linux Kind integration on Podman Desktop
1. Have podman installed and Open PD
2. Install Kind
3. Start Cluster in Settings -> Resources
4. Check the presence of `kind-control-plane` container
5. Pull an image
6. Start a container
7. Create a pod from container => Deploy to Kubernetes
8. Check tak pod is created
9. Verify deployed podified application that is available on kubernetes cluster (ToDo)

### Windows and Mac OS Kind integration on Podman Desktop
1. requires podman
    *  Install podman, initialize and start it
2. Download the kind for the system via PD -> click on Kind button in bottom left corner
3. go to settings -> resources and check Kind resource
4. Create new kind cluster via Kind -> create new...
5. Choose correct fields (defaults) and click create
6. verify the form and click `Show Logs` to verify the progress, you will get a message that you can
7. If your podman machine did not have root connection set you need to:
    *  go to powershell and run `podman system connection default podman-machine-default-root` to make podman system connection with root the one that is default
    *  restart podman machine in settings -> resources
8. Create a kind cluster (Settings -> Resources)
9. Verify that cluster was created (powershell) and that it exists on Kind Resources (known issue) in Settings
10. Check the presence of `kind-control-plane` container
11. Pull an image
12. Start a container
13. Create a pod from container => Deploy to Kubernetes
14. Check tak pod is created
15. Verify deployed podified application that is available on kubernetes cluster (ToDo)

## Known issues
* When behind VPN, the restrictor can cause network or some services inaccessibility in containers, could results in container errors like `ErrImagePull` or `ImagePullBackOff`, to debug use `kubectl desribe pod <pod-name>`, resources: [Kubernetes ImagePullBackOff error](https://www.tutorialworks.com/kubernetes-imagepullbackoff/)
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
