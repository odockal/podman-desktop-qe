# Podman Resource testing (Mac OS and Windows)

## Introduction

We want to make sure, that podman engine is properly installed on the host machine and can be used to utilize containers technologies.
On linux, podman is native to the system (it uses libpod library) and does not require the resources that are necessary on Windows and Mac Os systems.
Thus Podman Machine concept or podman remote is only a matter of windows or Mac OS platforms.

## Linux

On linux we can verify that podman package is installed on the system by looking at Dashboard, where Podman is detected if available on the system and in what version. On Settings -> Resources we can check the "tile" of a podman resource which contains the basic information.

## Windows and Mac OS
Both systems require that you install Podman onto the system, usually done via Podman Desktop that offers that installation of the Podman remote/client version that is tied to a particular Podman Desktop. It is hardcoded. Once the podman is installed, you can follow up with initializatin the podman machine. 

### Create a machine - initialize and start
On both windows and Mac you can initialize (`podman machine init`) and start (`podman machine start`) default podman machine from a Podman Desktop Dashboard. The default machine should be rootless and with a default resources gathered to operate podman in the host's newly create VM using partiocular VM's hypervisor (On Mac it can be qemu, on Windows WSL). Both require nested virtualization and uses podman remote (client) on the host system to "communicate" with a podman installed in the (usually linux based - ie. fedora) VM. On windows, `podman-wsl-fedora` image is used, on Mac os, it is `fedora-coreos`.

Once the machine is initialized, it can be either started from dashboard using Run Podman Button, or from Settings -> Resources, podman resource. It can be verified by `podman machine ls` from cli. 

Once the mahcine is started, OCI engine offers now the options to pull images, run image to get containers and create pods (and many more). 
Verification can be done from cli.

### Operating the machine
If the machine is up and running, we can see in Settings -> Resources, multiple actions -> Stop, restart, delete, open details - summary and log.
Verify that machine is operatinal by running all actions, and verifying UI changes between various status changes.

### Rootless and rootful - multiple machines at once on podman desktop
Default machinse is created in a rootless mode. In order to start a machine in a rootful mode, create a machine with a custom setup from Settings -> Resources. Second machine that is created, is usually in a stopped state. Starting such machine, when there is already one existing, leads to a dialog, that allows the user to define a default machine connection (aka podman system connection). Which decide what connection to the podman service will be used, mainly, what user and socket. Having set right connection allows proper functioning, viewing and manupulating with containers on the podman side. Misconfigured podman and podman connection leads to errors on podman desktop side (and podman's).
Verification of the connection can be done in powershell (`podman system connection ls`).

### Differences
On windows, more than one machine can be started at the same time. It opens another UI drop down menu, for example when you are pulling an image -> You can choose a container engine to use to perform an operation. 