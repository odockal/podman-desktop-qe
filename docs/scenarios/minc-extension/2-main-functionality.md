# Main functionality
This document covers how to complete the test cases from the second section of the `MINC extension` test sheet. In the first test case it is presumed that:
- `Podman` and the `Podman extension` are installed
- The `MINC extension` is installed 
- Podman Desktop is open

Version of the extension used for the purposes of this document: `0.4.0`.

### Attempt to create Microshift cluster
_Requirement: Have a rootless Podman machine running._

Microshift clusters can only be created through MINC extension using a rootful Podman machine. If you are using a rootless machine it is expected to run into an error. In order to check this behavior:
- Go to **Settings/Resources**, click on the **Create new...** button
- If you don't have minc installed:
    - Leave default settings
    - Click on **Create** button    
- An error message with the text `MINC requires a rootful Podman Machine. Please start a rootful Podman machine and try again.` should appear

### Create a Microshift cluster
_Requirement: Have a rootful Podman machine running._

- Go to **Settings/Resources**, click on the **Create new...** button
- Leave default settings
- Click on **Create** button   
- If you don't have minc installed, Podman Desktop will open a window to prompt you to install it, say `Yes`. When you give permissions to install it, a task in the background will appear and after a while minc will be installed.
- Eventually, the Microshift cluster should be created and started

### Install minc through Podman Desktop
The process is defined in the previous test case

### Stop, Start, and Restart the cluster
Go to **Settings/Resources**, try to `Stop`, `Start`, and `Restart` the current cluster

### Deploy a pod/container (ie. httpd-24) to the cluster
- Go to `Images`, click on `Pull`, paste `registry.access.redhat.com/ubi8/httpd-24` in the field and click on `Pull image`
- Go back to `Images`, click on the `Run Image` button from the image you just pulled
- Leave default settings, click on `Start Container`
- Go to `Containers`, click on the context menu of the newly created container, and click on `Deploy to Kubernetes`
- On the new window, toggle on the `Expose Service Locally Using Kubernetes Ingress` option and select a port (8080 e.g.)
- Make sure that the `Kubernetes Context` option is `microshift` and click on `Deploy`

This feature is currently broken

### Can delete the cluster
- Go to **Settings/Resources**, on the `MicroShift` card, click on the `Stop` button. After it has finished stopping, click on the `Delete` button
- The button `Create new...` should've appeared again in the card