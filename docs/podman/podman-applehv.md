# Using Podman V4/V5 with Apple HV provider on Mac OS

## Podman V4
Default podman provider on Mac os for version 4 is qemu. qemu binary is usually downloaded and installed via podman pkg installer.
For Podman Desktop, this installer is always used. Pkg installer can also be downloaded via release pages. Installation via brew, which is also possible is not recommended since both qemu and podman are not tight together with a version restriction in mind. So you can have podman installed that works, but qemu are having some issues in the latest version provided by a brew.

### Enablement of applehv using vfkit
To use applehv provider with podman v4, install podman, and then create/update `~/.config/containers/containers.conf` file to have:

```
[machine]
  provider = "applehv"
```

You also need to have [vfkit](https://github.com/crc-org/vfkit) installed. Easier is to install vfkit via brew:

```
brew tap cfergeau/crc
brew install vfkit
```

Or you can set it up manually:
1. Download vfkit binary (from release pages)
2. make it executable: `chmod +x vfkit`
3. Remove it from quarantine: `xattr -dr com.apple.quarantine vfkit`
4. Put it on the PATH: `sudo mv vfkit /usr/local/bin/`

## Podman v5

Podman v5 installer already contains `vfkit` so there is not need to get it outside of installer, also no need to setup `applehv` provider, since it is default for podman v5.

## Verify machine's provider
Verify the provider by looking at the provider used during `podman machine init --log-level=debug`.
Or you can create a machine `podman machine init --now` and inspect it with `podman machine ls machine-name --format json` and check `VMType` field.