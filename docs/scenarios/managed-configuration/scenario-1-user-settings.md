# Testing scenarios for Managed Configuration (user-defined settings.json)

## Prerequisities
1. Podman installed
2. Podman Desktop is installed and not running
3. Onboarding was completed
4. Delete configuration files:
  * Managed Configuration Default Settings
    * `/usr/share/podman-desktop/default-settings.json`
    * `/Library/Application Support/io.podman_desktop.PodmanDesktop/default-settings.json`
    * `%PROGRAMDATA%\Podman Desktop\default-settings.json`
  * Locked Settings
    * `/usr/share/podman-desktop/locked.json`
    * `/Library/Application Support/io.podman_desktop.PodmanDesktop/locked.json`
    * `%PROGRAMDATA%\Podman Desktop\locked.json`
5. Prepare contents of `User Settings (settings.json)` with a custom value (e.g.: `"preferences.appearance": "light"`)

### Testing scenario

1. Start Podman Desktop
2. Theme should be set to `light` and reset property button should be visible
3. Set appearance preference to `dark`
4. `settings.json` should be updated
5. Use reset preference button
6. `"preferences.appearance"` should disappear from `settings.json`
7. UI should say `system` - [currently bugged, restarting PD fixes interface](https://github.com/podman-desktop/podman-desktop/issues/15242)
