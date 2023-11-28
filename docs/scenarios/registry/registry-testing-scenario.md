# Registry testing scenario

### Basic Registry verification
Verify Registry handling by adding new authenticated repository, editing it and removing. Also default registry records should be present and configuration works for them. One can also test showing password, etc.

### Pulling a private image - getting an error
1. Open Podman Desktop
2. Images -> Pull Image
3. `ghcr.io/username/alpine-hello:latest`
4. Pull
5. Assert that error message appears -> user is not authenticated (HTTP code 500)

### Adding Authneticated Registry into Podman Desktop and pulling a private image
1. Open Podman Desktop
2. Settings -> Registry
3. Add new registry (or you can update default `GitHub` record)
4. Registry url: `ghcr.io`
5. Username: `username`
6. Password: `your_token`
7. Login
8. Pull image as described above
9. Assert: Image was pulled, press done, open Images and check image is there.