# Uninstall Podman desktop, kind, compose and Podman on Linux (Fedora)

## Kind/compose/podman binary clean up
1. Clean up running containers and pulled images - in case of kind, one can use UI to delete kind cluster, or run `kind delete clusters --all`
2. Depending on what we tweaked along the way, we need to revert (/docs/scenarios/kind/kind-testing-scenarios.md)
* setting up kind to be run as rootless
* using rootless or rootful podman on the system
3. Remove Kind/Compose/Podman (local) binary
* System wide installation of binaries, ie.: `whereis kind` - `rm /usr/bin/kind`
* Podman Desktop installed binaries and plugins: `/home/user/.local/share/containers/podman-desktop/extensions-storage/podman-desktop.*`

## Podman uninstallation
1. The question is once the podman is built-in package of Fedora distro, if we want to remove it from the system
2. Removing user specific containers files: `/home/user/.local/share/containers`
3. Remove podman packages via dnf/yum. Caution, this will remove also dependencies.
4. Remove other files as suggested here ie. https://crunchtools.com/testing-with-podman-complete-uninstall-reinstall/ - I do not recommend.

## Podman Desktop
1. Uninstall podman desktop the way it was installed - either flatpak, flathub or using tarball (remove the tar) - see (/docs/installation/podman-desktop-linux-installation.md)