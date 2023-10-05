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