# Image testing scenario

## Example images for various purposes

| Registry/Organization/Image name:tag  | Authenticated | uses restricted ports (< 1000) | Approx. size (MB) | Container running after start up |
| :---------------- | :------:  | :----: | ----: | :----: |
| docker.io/library/nginx:latest                | No | Yes | 200 | Yes |
| quay.io/sclorg/nginx-122-micro-c9s            | No | Yes | 70 | Yes |
| docker.io/library/httpd:latest                | No | Yes | 150 | Yes |
| quay.io/sclorg/httpd-24-c9s:latest            | No | No| 300 | Yes |
| quay.io/sclorg/httpd-24-micro-c9s:latest      | No | No | 60 | Yes |
| registry.redhat.io/ubi8/httpd-24              | Yes | No | 450 | Yes |
| registry.access.redhat.com/ubi8/httpd-24      | No | No | 450 | Yes |
| registry.redhat.io/ubi8/nginx-122             | Yes | No |450 | Yes |
| registry.access.redhat.com/ubi8/nginx-122     | No | No | 450 | Yes |
| docker.io/library/alpine                      | No | N/A | 8 | Yes |
| ghcr.io/linuxcontainers/alpine:latest         | No | N/A | 8 | Yes |
| mirror.gcr.io/library/alpine                  | No | N/A | 8 | Yes |
| public.ecr.aws/docker/library/alpine:latest   | No | N/A | 8 | Yes |
| quay.io/podman/hello                          | No | N/A | 1   | No |

## Verificaton of Pulling of an image from unauthenticated source

1. Pull any image from the list above, where authentication is not required
2. Verify that image record (row) now appears on Images page

## Pull image from authenticated source

- described in [registry testing scenario](https://github.com/odockal/podman-desktop-qe/blob/main/docs/scenarios/registry/registry-testing-scenario.md)

## Build an image from containerfile

1. Create containerfile, ie. `httpd-24-local.yaml` with the following content:
```sh
FROM quay.io/centos7/httpd-24-centos7
```
or use the one available [online](https://github.com/odockal/podman-desktop-qe/blob/main/examples/images/ubi8-httpd-24.containerfile)
2. Build an image from containerfile mentioned above (ie. `httpd-24-local.yaml`), name it, ie. `httpd-local`
3. Verify that image was created and container can be created from the image
* Later, when using locally built image, it needs to be pushed to the cluster in order to be available in the particular provider
