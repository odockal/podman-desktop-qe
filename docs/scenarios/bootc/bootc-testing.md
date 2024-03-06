# Testing scenarios using bootC extension

## Prerequisities
1. Podman installed

## Instalation and starting up of OpenShift local extension

1. Open Podman Desktop Settings -> Extensions
2. Install a new extension from OCI Image -> `ghcr.io/containers/podman-desktop-extension-bootc`
3. Verify that bootc extension is present under Settings -> Resources

## Using bootc extension to create a bootable image

1. Go to Images menu and pull: `quay.io/centos-bootc/fedora-bootc:eln`
    Note: Currently only `quay.io/centos-bootc/fedora-bootc:eln` is supported.
2. 
