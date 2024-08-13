# Podman Remote feature verification

Reference implementation: https://github.com/containers/podman-desktop/issues/279

### Reusing Podman Machine to enable podman remote

In this scenario, we would like to reuse existing podman machine, since it has all we need to use podman-remote feature.

We assume that since podman machine ha severything set for us, we can remove files necessary for Podman Desktop to "see" the podman machine and its content and replace it by using podman remote features.

1. Create and start podman machine: `podman machine init --now` could have `--rootful`
2. List system connections: `podman system connection ls`
3. We will get something like: 
```
podman-machine-default-root  ssh://root@127.0.0.1:34127/run/podman/podman.sock            /home/odockal/.local/share/containers/podman/machine/machine  true        true
```
4. Open Podman Desktop (we could use cli, but we need to use the podman on the machine side when on linux)
5. Open Resources and check that we can see podman Machine (on linux, we will see two connections)
6. Pull an image and use Podman Machine Engine (ie. `ghcr.io/linuxcontainers/alpine`)
7. Check that image is visible in Podman Desktop
8. Remove the podman machine files from the system so that Podman Desktop no longer shows content of the remote machine
9. `podman system connection rm podman-machine-default`, `podman system connection rm podman-machine-default-root`
10. `rm -rf /run/user/1000/podman/*podman-machine-default*`
11. `rm -rf ~/.config.containers/podman/machine/qemu/podman-machine-default*`
12. Restart Podman Desktop and check that machine is not visible anymore, and so it not the image
13. Create remote connection: `podman system connection add remotemachine-root --identity /home/odockal/.local/share/containers/podman/machine/machine  ssh://root@127.0.0.1:34127/run/podman/podman.sock` - notice that we still have ssh file and we are using the same identity to use podman remote
14. Enable Podman Remote in Podman Desktop -> Settings -> Preferences -> Extension: Podman -> Remote
15. Assert that Remote connection is present and running in the Resources
16. Open Images/Containers and check that what was previously present on the podman machine is again visible, pull some image, start container etc.
17. Disable the Remote podman and check that all images are again not visible

### Clean up

Since we have lost access to the machine as set during podman machine init, we need to find VM, processes, etc. and clean them up manually.

0. `podman machine reset -f`
1. `podman system connection rm remotemachine-root`
2. `rm -rf ~/.config/containers`
3. `rm -rf ~/.ssh/podman-machine-default*`
4. `rm -rf ~/.local/share/containers/podman`
5. On Linux when using qemu: `ps -ef | awk -e '/qemu/ && !/awk/' | sed -e 's/[^/]*//' -e 's/ -/\n\t-/g'` and kill these processes
6. On Win - open powershell and look for machine using `wsl --list` or open HyperV Manager
7. On Mac: probably similar to linux but maybe replace qemu with libkrun or vfkit