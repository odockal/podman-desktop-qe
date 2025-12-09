# Testing scenarios for Managed Configuration (managed default-settings.json and locked.json)

## Prerequisities
1. Podman installed
2. Podman Desktop is installed and not running
3. Delete configuration files:
  * User Configuration Files
    * `~/.local/share/containers/podman-desktop/configuration/settings.json`
    * Mac is identical
    * `%USERPROFILE%\.local\share\containers\podman-desktop\configuration\settings.json`
5. Preconfigure managed configuration `Default Settings (default-settings.json)` (e.g.: `"preferences.appearance":"dark"`)
6. Predefine locked.json e.g.:
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
4. Preference should be set to `dark`
5. Changing values should have no effect
6. Use of reset preference button should have no effect
7. `"preferences.appearance"` should change back to `dark` - [currently bugged, restarting PD fixes settings.json content](https://github.com/podman-desktop/podman-desktop/issues/15297)
8. UI should say `dark` - [currently bugged, restarting PD fixes interface](https://github.com/podman-desktop/podman-desktop/issues/15242)
