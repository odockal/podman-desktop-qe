# Podman installation on Windows using a nightly bits.
Motivation to test nightly Podman bits with a Podman Desktop application is to catch possible breakages and bug before release testing and soon in the process.

## Problem

Podman installation on Windows or mac OS system differs from linux as Podman is natively supported on Linux platform. In order to have podman working on Windows and Mac OS platform, the virtualization needs to step in. The client - server architecture is used and so we have Podman running inside a VM (server) on given host with exposed socket and a client that communicates with its server part. 

Podman Desktop offers to install (some) version of a podman on the system using its installer. Installer take podman client and installs in on the system (putting on the system PATH), and then client have specified, what base image should be used to spawn up a VM on a host.

We can avoid this hard coded versions installation by manually downloading required podman client, and then using right image (with proper podman pacakge) to spin up the VM using `podman machine init`.

## Windows Fedora WSL base image for the host's VM

For Windows platform, Fedora WSL image is used as a VM system to provide a podman inside.

The locations to get an image: 
* If you want use same latest image, you can install podman client (see below) which will install some of the latest images
* Or you can download a concrete windows dedicated [Podman Fedora WSL image](https://github.com/containers/podman-wsl-fedora/releases)

## Windows Podman Client downloads

Podman has a [downloads guide](https://github.com/containers/podman/blob/main/DOWNLOADS.md) for various configurations.

Based on a client version to be used:
* [Latest released version of an installer of a podman installer](https://github.com/containers/podman/releases)
* [Nightly build for a podman client (zip) - x86_64](https://api.cirrus-ci.com/v1/artifact/github/containers/podman/Artifacts/binary/podman-remote-release-windows_amd64.zip)

## Example of using a podman nightly on Windows system
1. Download the client (zip)
2. Extract the archive and put `bin` folder on the PATH: `C:\Tools\podman-4.8.0-dev\usr\bin`
3. Download the required [podman WSL Fedora image](https://github.com/containers/podman-wsl-fedora/releases), if required
4. Either start a machine using an image `podman machine init --image-path ~/Downloads/rootfs.tar.xz` or simply using latest `podman machine init`
5. Start Podman Desktop

## Creating a custom podman-wsl-fedora image with newer podman than available on the site
1. Download the client (zip)
2. Extract the archive and put `bin` folder on the PATH: `C:\Tools\podman-4.8.0-dev\usr\bin` or install via msi installer
3. `podman machine init` - will use probably image with latest stable podman installed
4. `podman machine start`
5. `podman machine ssh`
6. `dnf install 'dnf-command(config-manager)'` - install dnf config manager to enable testing repository
7. Search for particullar repository with [podman](https://packages.fedoraproject.org/pkgs/podman/podman/) version you want to test
8. (Using updates-testing): `dnf config-manager --set-enabled updates-testing`
9. `sudo dnf update podman` -> To get the version installed on the VM's image
10. `podman version` -> should show latest podman engine (ie. 4.8.0)
11. `exit` - leave the VM
12. Check the podman on the host, we still see old version, expect 4.8.0 client and 4.8.0 server:
```sh
podman version
Client:       Podman Engine
Version:      4.8.0
API Version:  4.8.0
Go Version:   go1.20.5
Git Commit:   c4dfcf14874479e34b3f312f089fc5840e306258
Built:        Mon Nov 27 19:37:20 2023
OS/Arch:      windows/amd64

Server:       Podman Engine
Version:      4.7.2
API Version:  4.7.2
Go Version:   go1.20.10
Built:        Tue Oct 31 15:30:11 2023
OS/Arch:      linux/amd64

```
13. `podman machine stop`, `podman machine start` - restarting the machine should bring reuired version in
14. Assert: `podman version`  -> 4.8.0 for both parts
```sh
podman version
Client:       Podman Engine
Version:      4.8.0
...
Server:       Podman Engine
Version:      4.8.0
...

```
15. Export the image: `wsl --list` to get actual machine name, then `wsl --export podman-machine-default image-target.tar`
16. After process is successful, assert the image size: `ls`
```sh
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         12/5/2023   9:50 AM      904826880 podman-wsl-fedora-4.8.0-fc38.tar
```
17. Now you can use custom image with specific podman version to create a podman machine on windows
18. Either in podman desktop or using `podman init` in powershell with image path flag: `podman machine init --image-path image-target.tar`