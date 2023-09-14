#!/bin/bash

# pull image docker.io/library/httpd, create a container, start it, stop it and delete it all using podman REST api - compat.

# podman unix socket is running, thus api is available

# podman system service --timeout 5000

# test -> `podman info` using compat REST API
curl -X GET --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http://v1.44/info | python -m json.tool

# Pull an image first
curl -X POST --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/images/create?fromImage=docker.io/library/alpine:latest

# Create a container from given image, payload in json local file
curl -X POST -H "Content-Type: application/json" --data @httpd-container-payload.json --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/create?name=my-alpine

# OR
curl -X POST -H "Content-Type: application/json" -d '{
  "Image": "docker.io/library/alpine",
  "Names": ["my-alpine"],
  "Tty": true,
  "AttachStdin": false,
  "AttachStdout": true,
  "AttachStderr": true,
}' --unix-socket $XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/create?name=my-alpine

# Start a container
curl -I -X POST --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/my-alpine/start

# Stop a container
curl -I -X POST --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/my-alpine/stop

# Delete a container
curl -I -X DELETE --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/my-alpine
