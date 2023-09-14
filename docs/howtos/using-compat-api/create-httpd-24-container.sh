#!/bin/bash

# pull image docker.io/library/httpd, create a container, start it, stop it and delete it all using podman REST api - compat.

# podman unix socket is running, thus api is available

# podman system service --timeout 5000

# test -> `podman info` using compat REST API
curl -X GET --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http://v1.44/info | python -m json.tool

# Pull an image first
curl -X POST --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/images/create?fromImage=docker.io/library/httpd:latest

# Create a container from given image, payload in json local file
curl -X POST -H "Content-Type: application/json" --data @httpd-container-payload.json --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/create?name=httpd-from-api

# OR
curl -X POST -H "Content-Type: application/json" -d '{
  "Image": "docker.io/library/httpd",
  "Names": ["httpd-from-api"],
  "Tty": true,
  "AttachStdin": false,
  "AttachStdout": true,
  "AttachStderr": true,
  "HostConfig": {
    "PortBindings": {
      "80/tcp": [
        {
          "HostPort": "8080"
        }
      ]
    }
  }
}' --unix-socket $XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/create?name=httpd-from-api

# Start a container
curl -I -X POST --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/httpd-from-api/start

# Stop a container
curl -I -X POST --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/httpd-from-api/stop

# Delete a container
curl -I -X DELETE --unix-socket /$XDG_RUNTIME_DIR/podman/podman.sock http:/v1.44/containers/httpd-from-api
