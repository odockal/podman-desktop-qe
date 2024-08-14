# Podman Remote feature verification

Reference implementation: https://github.com/containers/podman-desktop/issues/279
Resources for undestading the podman machine: https://www.redhat.com/sysadmin/podman-mac-machine-architecture 

### Reusing Podman Machine to enable podman remote

In this scenario, we would like to reuse existing podman machine, since it has all we need to use podman-remote feature.

We assume that since podman machine has severything set for us, we can remove files necessary for Podman Desktop to "see" the podman machine and its content and replace it by using podman remote features.

1. Create and start podman machine: `podman machine init --now` could have `--rootful`
2. List system connections: `podman system connection ls`
3. We will get something like: 
```
podman-machine-default-root ssh://root@127.0.0.1:34127/run/podman/podman.sock /home/odockal/.local/share/containers/podman/machine/machine true true
```
4. Open Podman Desktop (we could use cli, but we need to use the podman on the machine side when on linux)
5. Open Resources and check that we can see podman Machine (on linux, we will see two connections)
6. Pull an image with use of Podman Machine Engine (ie. `ghcr.io/linuxcontainers/alpine`)
7. Check that image is visible in Podman Desktop

Since the access to the VM is provided by `gvproxy`, you can check what `IP:PORT` is used by the app to allow communication between host and VM by mapping the ports between then, ie:
```
sudo lsof -i -P -n | grep LISTEN | grep gvproxy
gvproxy   13603         user    8u  IPv4 133682      0t0  TCP 127.0.0.1:39277 (LISTEN)
```

#### Reusing Existing Podman Machine ssh key 

1. Remove the podman machine files from the system so that Podman Desktop no longer shows content of the remote machine
2. `podman system connection rm podman-machine-default`, `podman system connection rm podman-machine-default-root`      
3. `rm -rf /run/user/1000/podman/*podman-machine-default*`
4. `rm -rf ~/.config/containers/podman/machine/qemu/podman-machine-default*`
5. Restart Podman Desktop and check that machine is not visible anymore, and so it not the image
6. Create remote connection: `podman system connection add remotemachine-root --identity /home/odockal/.local/share/containers/podman/machine/machine  ssh://root@127.0.0.1:34127/run/podman/podman.sock` - notice that we still have ssh file and we are using the same identity to use podman remote

#### Adding new ED25519 Keys

Create new ssh ED25519 key pair and add them into the remote machine as authorized keys

1. Generate new ED25519 keys on your host machine (not VM): `ssh-keygen -t ed25519 -C "user@machinename"`
2. It will produce ssh key pair in your `~/.ssh` location named: `id_ed25519` and `id_ed25519.pub`
3. Connect to the podman machine: `podman machine ssh` (we are still using former connection)
4. Add public part of the key to the authorized keys: `echo "...public ed25519 key..." > .ssh/authorized_keys.d/remote`
5. Adjust the permission of the file: `chmod 600 .ssh/authorized_keys.d/remote`

Remove actual connection to the podman machine

1. Remove the podman machine files from the system so that Podman Desktop no longer shows content of the remote machine
2. `podman system connection rm podman-machine-default`, `podman system connection rm podman-machine-default-root`      
3. `rm -rf /run/user/1000/podman/*podman-machine-default*`
4. `rm -rf ~/.config/containers/podman/machine/qemu/podman-machine-default*`
5. Restart/Force Reload Podman Desktop and check that machine is not visible anymore, and so is the image
6. We need to find out the port used by gvproxy to access the VM: `sudo lsof -i -P -n | grep LISTEN | grep gvproxy`
7. Create remote connection: `podman system connection add remotemachine-root --identity /home/user/.ssh/id_ed25519 ssh://root@127.0.0.1:XXXXX/run/podman/podman.sock`
8. Set connection default if necessary: `podman system connection default remotemachine-root`

#### Verification of the Podman Remote feature

1. Enable Podman Remote in Podman Desktop -> Settings -> Preferences -> Extension: Podman -> Remote
2. Assert that Remote connection is present and running in the Resources
3. Open Images/Containers and check that what was previously present on the podman machine is visible again, pull some images, start containers etc.
4. if you run `podman images` on cli, it should not show the image in the remote machine
5. Disable the Remote podman feature and check that all images are not visible

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
8. Remove manually created ssh keys: `rm -rf ~/.ssh/id_ed25519*`