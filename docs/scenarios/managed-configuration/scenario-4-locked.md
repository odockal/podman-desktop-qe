# Testing scenarios for Managed Configuration (locked.json only)

## Prerequisities
1. Podman installed
2. Podman Desktop is installed and not running
3. Delete configuration files:
  * User Configuration Files
    * `~/.local/share/containers/podman-desktop/configuration/settings.json`
    * Mac is identical
    * `%USERPROFILE%\.local\share\containers\podman-desktop\configuration\settings.json`
  * Managed Configuration Default Settings
    * `/usr/share/podman-desktop/default-settings.json`
    * `/Library/Application Support/io.podman_desktop.PodmanDesktop/default-settings.json`
    * `%PROGRAMDATA%\Podman Desktop\default-settings.json`
4. Predefine locked.json e.g.:
```
{
  "locked": [
    "preferences.appearance"
  ]
}
```

### Testing scenario

1. Start Podman Desktop
2. Finish onboarding
3. Observe contents of `User Configuration Files`
4. Preference should have a `Managed` label next to it
5. UI behavior in this scenario is undefined, currently the interface elements are not locked, changing value is possible