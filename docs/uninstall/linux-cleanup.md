# Uninstall Podman desktop, kind, compose and Podman on Linux (Fedora)

## Kind/compose/kubectl/minikube binary clean up
1. Clean up running containers and pulled images - in case of kind, one can use UI to delete kind cluster, or run `kind delete clusters --all`
2. Minikube clean up of the clusters and configuration -> `minikube delete`
3. Depending on what we tweaked along the way, we need to revert (/docs/scenarios/kind/kind-testing-scenarios.md)
* setting up kind to be run as rootless
* using rootless or rootful podman on the system
4. Remove Kind/Compose/kubectl/minikube (local) binary
* System wide installation of binaries, ie.: `whereis kind` - `rm /usr/local/bin/kind`
* Podman Desktop installed binaries and plugins: `/home/user/.local/share/containers/podman-desktop/extensions-storage/podman-desktop.*` (some extensions start with `redhat`)

## Remove Containers, pods, images, machines
1. Force remove all containers: `podman rm -a -f`
2. Force remove all pods: `podman pod rm -a -f`
3. Force remove all images: `podman rmi -a -f`
4. Force remove all podman machines and reset: `podman machine reset -f`

## Podman Desktop
1. Uninstall podman desktop the way it was installed - either flatpak, flathub or using tarball (remove the tar) - see (/docs/installation/podman-desktop-linux-installation.md)
2. Flatpak/Flathub uninstallation: `flatpak uninstall io.podman_desktop.PodmanDesktop`
3. Remove Podman Desktop Home Confoguration Folder (removes settings, extensions, etc.) - `rm -rf `~/.local/share/containers/podman-destkop`

## Podman uninstallation - Caution, this is used for testing purposes only
1. The question is once the podman is built-in package of Fedora distro, if we want to remove it from the system
2. Podman configuration files - `~/.config/containers/`
3. Removing user specific containers files: `/home/user/.local/share/containers`
4. Remove podman packages via dnf/yum. Caution, this will remove also dependencies
5. Remove other files as suggested here ie. https://crunchtools.com/testing-with-podman-complete-uninstall-reinstall/ - I do not recommend.
