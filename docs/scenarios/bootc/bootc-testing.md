# Testing scenarios using bootC extension

## Prerequisities
1. Podman installed

## Instalation and starting up of BootC extension

1. Open Podman Desktop Extensions -> Catalog
2. Install Custom... -> `ghcr.io/containers/podman-desktop-extension-bootc`
3. Verify that bootc extension is present under Extensions -> Installed

## Using bootc extension to create a bootable image

1. Go to Images menu and pull: `quay.io/centos-bootc/centos-bootc:stream9`
    Note: Currently only `quay.io/centos-bootc/centos-bootc:stream9` is supported.
2. From the action menu select `Build Disk Image` option.
3. From the drop down menu select the build image type. Types available are `QCOW2`, `AMI`, `RAW` and `ISO`.
4. From the drop down menu select the architecture type. Architecture types available are `ARM64` and `AMD64`.
5. Enter the path where the output folder will be stored and afterwards press `Enter`.
6. At this point the building should start, you can follow the progress in that `Tasks` menu from the bottom bar. (click on the Bell icon).
7. If no error is encountered when the process finishes the image should be available in the output folder entered.
