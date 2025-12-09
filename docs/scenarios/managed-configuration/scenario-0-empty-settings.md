# Testing scenarios for Managed Configuration (no configuration files)

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
  * Locked Settings
    * `/usr/share/podman-desktop/locked.json`
    * `/Library/Application Support/io.podman_desktop.PodmanDesktop/locked.json`
    * `%PROGRAMDATA%\Podman Desktop\locked.json`

### Testing scenario

1. Start Podman Desktop
2. Finish onboarding
3. Observe contents of `User Configuration Files`
4. Set appearance preference to `light`
5. `settings.json` should be updated
6. Use reset preference button
7. `"preferences.appearance"` should disappear from `settings.json`
8. UI should say `system` - [currently bugged, restarting PD fixes interface](https://github.com/podman-desktop/podman-desktop/issues/15242)
