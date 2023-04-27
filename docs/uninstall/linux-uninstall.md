# Uninstall Podman desktop and Podman on Linux (Fedora)

1. Clean up running containers and pulled images
2. The question is once the podman is built in package, if we want to remove it from the system
3. Removing user specific containers files: `/home/user/.local/share/containers`
4. Depending on what we tweak along the way, we need to revert 
* setting up kind to be run as rootless
* using rootless or rootful podman on the system
5. Remove podman packages via dnf/yum. Caution, this will remove also dependencies.
6. Remove other files as suggested here ie. https://crunchtools.com/testing-with-podman-complete-uninstall-reinstall/ - I do not recommend.

1. Uninstall podman desktop the way it was installed - either flatpak, flathub or using tarball (remove the tar)