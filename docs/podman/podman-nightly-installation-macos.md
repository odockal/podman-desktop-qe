# Podman installation on Mac OS using a nightly bits.
Motivation to test nightly Podman bits with a Podman Desktop application is to catch possible breakages and bug before release testing and soon in the process.

## Problem

Podman installation on windows or mac OS system differs from linux as Podman is natively supported on Linux platform. In order to have podman working on Windows and Mac OS platform, the virtualization needs to step in. The client - server architecture is used and so we have Podman running inside a VM (server) on given host with exposed socket and a client that communicates with its server part. 

Podman Desktop offers to install (some) version of a podman on the system using its installer. Installer take podman client and installs in on the system (putting on the system PATH), and then client have specified, what base image should be used to spawn up a VM on a host.

We can avoid this hard coded versions installation by manually downloading required podman client, and then using right image (with proper podman pacakge) to spin up the VM using `podman machine init`.

## Mac OS Fedora CoreOS base images

For Mac OS platform, Fedora Code OS image is used as a VM system to provide a podman inside.

The locations to get an image: 
* [Released Fedora Core OS site (next stream)](https://fedoraproject.org/coreos/release-notes/?arch=x86_64&stream=next)
* [Fedora Core OS Builds site - testing-devel stream](https://builds.coreos.fedoraproject.org/browser?stream=testing-devel)

## Mac OS Podman Client/Installer downloads

Podman has a [downloads guide](https://github.com/containers/podman/blob/main/DOWNLOADS.md) for various configurations.

Based on a client version to be used:
* [Latest released version of an installer of a client](https://github.com/containers/podman/releases)
* [Nightly build for a podman installer (pkg) - x86_64](https://api.cirrus-ci.com/v1/artifact/github/containers/podman/Artifacts/binary/podman-installer-macos-amd64.pkg)
* [Nightly build for a podman installer (pkg) - arm64](https://api.cirrus-ci.com/v1/artifact/github/containers/podman/Artifacts/binary/podman-installer-macos-aarch64.pkg)
* [Or similarly ZIP files can be downloaded as well instead of pkg](https://api.cirrus-ci.com/v1/artifact/github/containers/podman/Artifacts/binary/podman-remote-release-darwin_amd64.zip)

## Example of using a podman nightly on a Mac OS
1. Download the installer (pkg)
2. Install it using `installer -pkg myapp.pkg -target CurrentUserHomeDirectory`, which should install the program under `/Applications`
3. Download the required fedora coreOS image (ie.: `https://builds.coreos.fedoraproject.org/prod/streams/testing-devel/builds/38.20230929.20.0/x86_64/fedora-coreos-38.20230929.20.0-qemu.x86_64.qcow2.xz`)
4. Prepare your podman machine with downloaded image: `podman machine init --image-path ~/Downloads/fedora-coreos.x.qcow.xz`
5. Start Podman Desktop
6. Assert: Podman used by podman desktop should be the one installed manually - `podman version`, check dashboard or Resources