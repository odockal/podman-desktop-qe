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
4. Preconfigure managed configuration `Default Settings (default-settings.json)` (e.g.: `"preferences.appearance":"light"`)

### Testing scenario

1. Start Podman Desktop
2. Finish onboarding
3. Observe contents of `User Configuration Files`
4. Set appearance preference to `dark`
5. `settings.json` should be updated
6. Use reset preference button
7. `"preferences.appearance"` should change back to `light` - [currently bugged, restarting PD fixes settings.json content](https://github.com/podman-desktop/podman-desktop/issues/15297)
8. UI should say `light` - [currently bugged, restarting PD fixes interface](https://github.com/podman-desktop/podman-desktop/issues/15242)
