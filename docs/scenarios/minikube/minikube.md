# Minikube Extension Testing

## Prerequisites

Ensure the following are installed:

- **Podman** or **Docker**
- **Virtualization Software** for Windows/Mac (e.g., WSL, Hyper-V, Libkrun, AppleHV), with minimum requirements:
  - **CPU**: 2 cores
  - **Memory**: 2048 MB
  - **Disk Size**: 20 GB

---

## Step 1: Install and Verify Basic Functionality of the Minikube Extension

1. Open the **Podman Desktop** and navigate to the **Extensions** page.
2. **Install the Minikube extension** from an OCI image.
3. **Verify Installation**: Check that the Minikube extension appears under the installed extensions tab on the Extensions page.

4. **Install Minikube CLI**:
   - Go to **Settings > CLI Tools**.
   - Find the **Minikube** card and click the **Install** button. Choose the desired CLI version.

5. **Verify CLI Installation**:
   - Navigate to **Settings > Resources** and confirm that the **Minikube** card is visible. This confirms that the extension is active and the CLI is installed.

6. Go to the **Extensions** page and open the **Minikube extension details page**. Verify the following:
   - **Status** should be **active**.
   - **Stop** and **Delete** buttons should be visible, and the **Stop** button should be enabled.

7. **Test Enable/Disable Functionality**:
   - Confirm the extension can be enabled and disabled from the details page.
   - Go back to the **Extensions** page and ensure that the extension can also be enabled or disabled from there.

   > **Note**: When the extension is inactive, the **Minikube** card on **Settings > Resources** should not be visible.

---

## Step 2: Minikube Cluster Installation

1. Go to **Settings > Resources** and click the **Create New** button under the **Minikube** card.

2. **Choose Driver and Runtime Options**:
   - On the cluster creation page, select the driver (Podman (experimental) / Docker) and container runtime (CRI-O, containerd, or Docker), then click the **Create** button.
   
   - **Rootful Setup**:
     - By default, Minikube runs in **rootful mode** with Podman/Docker. It is recommended to set the `container-runtime` to `cri-o`.

    > **Note**: The default Podman setup on Linux is **rootless**. Installing a **Minikube cluster** on Linux with the default Minikube settings of **rootful** Podman may cause issues. Specifically, the Minikube cluster does not appear on the **Settings > Resources** page, and the Minikube container does not show up on the **Containers** page in the Podman Desktop. For more details, refer to [this issue](https://github.com/podman-desktop/extension-minikube/issues/152).


   - **Rootless Setup**:
     - **Starting a cluster using the rootless Podman driver**:
       - Enable rootless mode using the `minikube` CLI with: `minikube config set rootless true`.
       - With rootless Podman, it is recommended to set `container-runtime` to `containerd`.
       - [Known Podman issues](https://minikube.sigs.k8s.io/docs/drivers/podman/#known-issues).
     
     - **Starting a cluster using the rootless Docker driver**:
       - Install Docker rootless mode with: `dockerd-rootless-setuptool.sh install -f`.
       - Set the Docker context to rootless: `docker context use rootless`.
       - When using rootless Docker, it is also recommended to set `container-runtime` to `containerd`.
       - [Known Docker issues](https://minikube.sigs.k8s.io/docs/drivers/docker/#known-issues).

   - For more information on drivers, refer to the [Minikube documentation](https://minikube.sigs.k8s.io/docs/drivers/).


3. **Post-Installation Checks**:
   - After the cluster installation, verify the following:
     - **Context Tray**: The Minikube context should be present and selected in the context tray.
     - **Settings > Resources**: The cluster should be listed under the **Minikube** tab, showing an active status and control buttons.
     - **Containers Page**: A Minikube container should be present and `running`.
     - **Volumes Page**: A volume bound to the Minikube container should be present and `used`.

    - Go to **Kubernetes > Nodes** and confirm that you are connected to the Minikube cluster and the node is running.
    - In **Kubernetes > Dashboard**, verify the presence of:
      - One **Node** (Minikube)
      - One **Service** (Kubernetes)
      - One **ConfigMap** (kube-root-ca.crt)

4. **Cluster Operations**
   - Ensure the cluster can be restarted, stopped, and deleted using the control buttons on the **Settings > Resources** page.

---

## Step 3: Testing Kubernetes Features with Minikube Cluster

Test the following Kubernetes features within the Minikube cluster:

- Services
- Deployments
- Routes/Ingress
- Kubernetes YAML Editing
- ConfigMaps and Secrets
- Persistent Volume Claims (PVCs)
- YAML Apply Feature
- Port Forwarding Feature

> **Documentation**: Full documentation for these test cases can be found [here](https://github.com/odockal/podman-desktop-qe/blob/b61b9ebf948e7770c240c2f809f7bbd0dab8a51b/docs/scenarios/kubernetes) (in progress).
