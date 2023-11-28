# How to create an image in a user packages registry on GitHub

We aim is to get an image to the user's packages on ghcr.io. This image can be then used in a testing scenario for Podman Desktop registry handling.

There are other options for a registry to use other than ghcr.io.:
* quay.io
* docker.io
* registry.access.redhat.com
* registry.redhat.io
* gcr.io
* gallery.ecr.aws
* Custom registry created on AWS or Azure, etc.

Main issue is that we want to avoid paid services, do not share personal/working account secrets on various CI system.
Easiest way (as for now) is to use packages feature from github.com, where the registry is also accessible easily on GitHub CI. 

This guide serves to provide a way to create an image locally, push it to the user's github.com registry space (packages) and use a dedicated token to be used in local scenario to push and eventually authenticate to the registry via Podman Desktop and get the image there.

### Create a token to get a way to authenticate into a registry
1. On the github profile, go to Settings -> Developer Settings -> Personall Access tokens -> Tokens (classic)
2. Generate new token (Classic)
3. Setup all necessary info (expiration for example, add note to distingusih the token purpose)
4. In case of just using the token for pulling an images, pick up: `read:packages` context
5. If you want to use the token to publish images, also add `write:packages`, `delete:packages`
* * This will also mark all `repo` context
5. Generate token -> Save token locally `~/.ssh/gh_token`
6. 

### Create a local image and push it into a ghcr.io registry
1. Checkout https://github.com/odockal/podman-desktop-qe
2. `cd podman-desktop-qe/examples/images/alpine-hello`
3. `podman build -f alpine-hello.containerfile -t alpine-hello`
4. `podman tag localhost/alpine-hello:latest ghcr.io/odockal/alpine-hello:latest`
5. `export GITHUB_TOKEN=$(cat ~/.ssh/gh_token)`
6. `echo $GITHUB_TOKEN | podman login ghcr.io -u USERNAME --password-stdin`
7. `podman push ghcr.io/odockal/alpine-hello:latest`
8. Verify that image is available: github.com -> your Profile -> Packages -> `alpine-hello`
9. Check you can pull an image: `podman pull ghcr.io/username/alpine-hello:latest`
10. Image is private, so it can be only pulled from an authenticated source

### Testing of the image
Could be done based on [registry testing doc](https://github.com/odockal/podman-desktop-qe/tree/main/docs/scenarios/registry/registry-testing-scenario.md)

## Resources

* [Working with the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
* [Managing GitHub packages using GitHub Actions workflows](https://docs.github.com/en/packages/managing-github-packages-using-github-actions-workflows)