# Testing scenarios for Managed Configuration (managed default-settings.json)

## Prerequisities
1. Podman installed
2. Podman Desktop is installed and not running
3. Delete configuration files:
  * User Configuration Files
    * `~/.local/share/containers/podman-desktop/configuration/settings.json`
    * Mac is identical
    * `%USERPROFILE%\.local\share\containers\podman-desktop\configuration\settings.json`
  * Locked Settings
    * `/usr/share/podman-desktop/locked.json`
    * `/Library/Application Support/io.podman_desktop.PodmanDesktop/locked.json`
    * `%PROGRAMDATA%\Podman Desktop\locked.json`
4. Preconfigure managed configuration `Default Settings (default-settings.json)` e.g.:
```
{
    "registries.defaults": [
        {
            "registry": {
                "prefix": "redhat.com",
                "location": "registry.access.redhat.com",
                "insecure": false,
                "blocked": false
            }
        },
        {
            "registry": {
                "prefix": "quay.io",
                "location": "quay.io",
                "insecure": false,
                "blocked": true
            }
        }
    ]
}
```

### Testing scenario

1. Start Podman Desktop
2. Finish onboarding
3. Observe contents of `User Configuration Files`
4. Verify contents of `$HOME/.config/containers/registries.conf` or `%USERPROFILE%\.config\containers\registries.conf`
5. Attempt to pull `quay.io/libpod/alpine_nginx`
    - should fail with `500`
6. Attempt to pull `registry.access.redhat.com/ubi9/ubi-minimal`
    - should succeed