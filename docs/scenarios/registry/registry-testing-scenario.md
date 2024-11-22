# Registry testing scenario

## Prerequisites
- Image registry requiring authentication.
- Example registries: `registry.redhat.io/ubi8/httpd-24` or `ghcr.io/username/alpine-hello:latest`
- Github example requires having pushed an alpine image to packages on github, detailed setup described 
[here](https://github.com/odockal/podman-desktop-qe/blob/main/docs/howtos/registries-and-images/creating-image-ghcr.md).

## Basic Registry verification
Verification of Image Registry handling is done by adding new authenticated image registry, loging in and editing its login details and finally removing it. 
Default registry records should be present and editing thier configuration works as well. Show password feature should also be tested.

### Pulling a private image - getting an error
1. Open Podman Desktop
2. Go to Images -> Pull
3. Input `registry.redhat.io/ubi8/httpd-24` (`ghcr.io/username/alpine-hello:latest`)
4. Pull image
5. Assert that error message appears -> user is not authenticated (HTTP code 500)

### Adding Authneticated Registry into Podman Desktop and pulling a private image
1. Open Podman Desktop
2. Go to Settings -> Registries, Add registry 
* (alternatively, the default `GitHub` record can also be updated)
3. Registry url: `registry.redhat.io` (`ghcr.io`)
4. Username: `redhat_username` (`github_username`)
5. Password: `your_redhat_token` (`github_token` - Github Personal Access Token)
6. Add
7. Go to Images -> Pull
8. Input `registry.redhat.io/ubi8/httpd-24` (`ghcr.io/username/alpine-hello:latest`)
9. Assert that Image was pulled, open Images and verify image is present

* Unauthenticated version of httpd can be obtained here: `registry.access.redhat.com/ubi8/httpd-24`