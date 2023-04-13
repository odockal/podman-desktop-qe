# Podman Desktop installation on Linux

## Topics

* [Building from source](#building-from-source)
* [Running from binary](#running-from-binary)
* [Installation from flatpak](#installation-from-flatpak)
* [Installation from flathub](#installation-from-flathub)

## Building from source

## Running from binary

## Installation from flatpak

## Installation from flathub

Before opening an issue, check the backlog of
[open issues](https://github.com/containers/podman-desktop/issues)
to see if someone else has already reported it.

If you find a new issue with the project we'd love to hear about it! The most
important aspect of a bug report is that it includes enough information for
us to reproduce it. So, please include as much detail as possible and try
to remove the extra stuff that doesn't really relate to the issue itself.
The easier it is for us to reproduce it, the faster it'll be fixed!

Please don't include any private/sensitive information in your issue!

## Working On Issues

Often issues will be assigned to someone, to be worked on at a later time.

If you are a member of the [Containers](https://github.com/containers) organization,
self-assign the issue with the `status/in-progress` label.

If you can not set the label: add a quick comment in the issue asking that
the `status/in-progress` label to be set and a maintainer will label it.

## Contributing

This section describes how to start a contribution to Podman Desktop.

### Prerequisites: Prepare your environment

You can develop on either: `Windows`, `macOS` or `Linux`.

Requirements:
* [Node.js 16+](https://nodejs.org/en/)
* [yarn](https://yarnpkg.com/)

Optional Linux requirements:
* [Flatpak builder, runtime, and SDK, version 22.08](https://docs.flatpak.org/en/latest/first-build.html)
  ```sh
  flatpak remote-add --if-not-exists flathub --user https://flathub.org/repo/flathub.flatpakrepo
  flatpak install --user flathub org.flatpak.Builder org.freedesktop.Platform//22.08 org.freedesktop.Sdk//22.08
  ```
* GNU C and C++ compiler
  Fedora/RHEL
  ```sh
  dnf install gpp-c++
  ```
  Ubuntu/Debian
  ```sh
  apt-get install build-essential
  ```

### Step 1. Fork and clone Podman Desktop

Clone and fork the project.

3. Login to [EXTERNAL_IP:9090](http://EXTERNAL_IP:9090) with credentials minio/minio123
4. Create the access credentials and add it to your terminal:

```sh
export AWS_ACCESS_KEY_ID=ID
export AWS_SECRET_ACCESS_KEY=SECRET
```

Or else you will encounter a: `NoCredentialProviders: no valid providers in chain. Deprecated.` issue.
5. Create a bucket named `test-update`.
