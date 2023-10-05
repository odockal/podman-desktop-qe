# Podman Desktop installation on Linux

## Building from source

Requirements for building from a source code can be found at [CONTRIBUTING.md](https://github.com/containers/podman-desktop/blob/main/CONTRIBUTING.md)
```sh
yarn install
yarn compile (or compile:current)
```

Artifacts can be found under `dist` folder.

## Running from binary

Given previous step, executable/binary can be found under `dist/linux-unpacked/`

## Installation from flatpak

Flatpak file can be downloaded from downloads link under any tag or release from [github releases](https://github.com/containers/podman-desktop/tags).
Or it can be built locally, see above step.

Installation then look like this:
```sh
flatpak install podman-desktop-0.0.202310021558-f531978.flatpak
```

## Installation from flathub

Bits can be also installed from FlatHub repository

To install latest stable bits run:
`flatpak install io.podman_desktop.PodmanDesktop`

Or if during a staging of a release, [flathub PR](https://github.com/flathub/io.podman_desktop.PodmanDesktop/pulls) contains a link for actual flathub record being created that can be tested, ie:

```sh
flatpak install --user https://dl.flathub.org/build-repo/49665/io.podman_desktop.PodmanDesktop.flatpakref
```
