# Testing scenarios for Managed Configuration (managed default-settings.json with application default value)

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
4. Preconfigure managed configuration with application default `Default Settings (default-settings.json)` (e.g.: `"preferences.appearance":"system"`)

### Testing scenario

1. Start Podman Desktop
2. Finish onboarding
3. Observe contents of `User Configuration Files`
4. `"preferences.appearance"` should not be present
5. Application logs should contain `[Managed-by]: Applied default settings for: ...`