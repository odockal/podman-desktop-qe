# Testing scenarios for Managed Configuration (user-defined settings.json and managed default-settings.json)

## Prerequisities
1. Podman installed
2. Podman Desktop is installed and not running
3. Delete configuration files:
  * Locked Settings
    * `/usr/share/podman-desktop/locked.json`
    * `/Library/Application Support/io.podman_desktop.PodmanDesktop/locked.json`
    * `%PROGRAMDATA%\Podman Desktop\locked.json`
4. Prepare contents of `User Settings (settings.json)` with a custom value (e.g.: `"preferences.appearance": "light"`)
5. Preconfigure managed configuration `Default Settings (default-settings.json)` (e.g.: `"preferences.appearance":"dark"`)

### Testing scenario

1. Start Podman Desktop
2. Finish onboarding
3. Observe contents of `User Configuration Files`
4. Preference should be set to `light` (`settings.json` takes precedence)
6. Use reset preference button
7. `"preferences.appearance"` should change back to `dark` - [currently bugged, restarting PD fixes settings.json content](https://github.com/podman-desktop/podman-desktop/issues/15297)
8. UI should say `dark` - [currently bugged, restarting PD fixes interface](https://github.com/podman-desktop/podman-desktop/issues/15242)
