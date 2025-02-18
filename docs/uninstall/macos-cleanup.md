# Podman Desktop, Kind/Minikube and Podman uninstallation process (partially unverified)

## Kind and Minikube clean up

1. Clean up running containers and pulled images - in case of kind, one can use UI to delete kind cluster, or run `kind delete clusters --all`
2. In case of using minikube - `minikube delete` and remove `~/.minikube`
3. Depending on what we tweaked along the way, we need to revert (/docs/scenarios/kind/kind-testing-scenarios.md)
* setting up kind to be run as rootless
* using rootless or rootful podman on the system

## Podman uninstallation

Based on https://github.com/containers/podman/issues/11319

0. Quit podman desktop
1. Depending on the way we have install podman (using brew or podman desktop)
2. Uninstallation process for podman - stop al machines and remove them
```sh
podman machine list
podman machine stop podman-machine-default

podman machine rm -f podman-machine-default
# Starting Podman v5 - you can reset the machine
podman machine reset -f
```
* If podman was install through brew
```sh
brew uninstall podman
```
* if podman was installed using podman desktop (unverified) - pkg
```sh
sudo /opt/podman/bin/podman-mac-helper uninstall
sudo rm /etc/paths.d/podman-pkg
sudo rm -rfv /opt/podman
```
* Removing docker symlink: `/var/run/docker.sock` 
```sh
$ docker run -d -p 80:80 docker/getting-started
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```
* Removing the Podman and Podman Machine related files and configurations
```
rm -rf ~/.local/share/containers/podman
rm -rf ~/.config/containers
# maybe also ~/.local/share/containers/storage and others folders
```

## Podman Desktop uninstallation

1. Depending on how we installed podman desktop
* using brew: `brew uninstall podman-desktop`
* Using dmg - probably the standard way how to remove apps from Mac OS (Using UI and drag'n'drop into trash)
2. Remove Podman Desktop Home Configuration folder with extensions and settings, etc.
* `rm -rf ~/.local/share/containers/podman-desktop`
