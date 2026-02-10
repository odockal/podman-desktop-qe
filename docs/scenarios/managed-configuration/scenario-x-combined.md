# Testing scenarios for Managed Configuration (combined placeholders — Linux)

## Prerequisites
1. Podman installed
2. Podman Desktop is installed and not running
3. Finish onboarding where required by the individual test
4. Delete or prepare configuration files as needed for the scenario:
  * User Configuration Files

    Usually the path for configuration file is defined in product.json: "paths"."config", ie:
    * linux binary or mac: `~/.config/containers/podman-desktop/configuration/settings.json`
    * linux flatpak `~/.var/app/io.podman_desktop/PodmanDesktop/config/containers/podman-desktop/configuration/settings.json`
    * windows: `%USERPROFILE%\.local\share\containers\podman-desktop\configuration\settings.json`
  * Managed Configuration Default Settings

    Usually the path for configuration file is defined in product.json: "paths"."managed", ie:
    - Linux: `/usr/share/podman-desktop/default-settings.json`
    - Mac: `/Library/Application Support/io.podman_desktop.PodmanDesktop/default-settings.json`
    - Windows: `%PROGRAMDATA%\Podman Desktop\default-settings.json`
  * Locked Settings

    Usually the path for configuration file is defined in product.json: "paths"."managed", ie:
    - Linux: `/usr/share/podman-desktop/locked.json`
    - Mac: `/Library/Application Support/io.podman_desktop.PodmanDesktop/locked.json`
    - Windows: `%PROGRAMDATA%\Podman Desktop\locked.json`

## Preparation (one-time combined)
Create the following files on the test machine before starting Podman Desktop. These are the concrete values to pre-set for the combined run.

- `User settings` (`settings.json`):
```
{
  "preferences.appearance": "system",
  "feedback.dialog": false,
  "tasks.Toast": true
}
```

- `Managed default settings` (`default-settings.json`):
```
{
  "feedback.dialog": true,
  "preferences.zoomLevel": 0.5,
  "preferences.ExitOnClose": false
}
```

- `Locked settings` (`locked.json`):
```
{
  "locked": [
    "terminal.integrated.lineHeight",
    "tasks.Toast",
    "preferences.ExitOnClose"
  ]
}
```

### Manually set configurations through UI during testing
* `podman.system.connections.remote`

### Testing scenario
1. Ensure Podman is installed and Podman Desktop is installed but not running.
2. Drop the prepared `settings.json`, `default-settings.json`, and `locked.json` into the appropriate locations. To test "no config" cases, remove those files instead.
3. Start Podman Desktop and finish onboarding (if required).
4. Verify initial UI state and file contents for each property below.

5. Property: `preferences.appearance` (user-only)
- Expectation: UI shows `system` (from the application default or effective value). Reset button visible.
- Steps:
  1. Verify `settings.json` contains `"preferences.appearance": "system"`.
  2. Change appearance in UI to `dark` → verify `settings.json` updated to `"preferences.appearance": "dark"`.
  3. Use the preference Reset action → verify `preferences.appearance` is removed from `settings.json` and the UI shows `system` (effective value from defaults/app).

6. Property: `feedback.dialog` (user + default)
- Expectation: user `false` overrides managed default `true` initially.
- Steps:
  1. Verify `settings.json` contains `"feedback.dialog": false` and `default-settings.json` contains `"feedback.dialog": true`.
  2. Confirm UI shows feedback dialog disabled.
  3. Toggle feedback dialog on in UI → verify `settings.json` updated to `true` and the UI shows feedback dialog enabled.
  4. Use the preference Reset action → verify the user-level override is removed (confirm `settings.json` no longer contains `"feedback.dialog"`) and the effective value returns to the managed default `true` (confirm `default-settings.json` still contains `"feedback.dialog": true`).

7. Property: `tasks.Toast` (user + locked)
- Expectation: Key is present in `settings.json` and also listed in `locked.json`; UI may show a Managed label and should not allow persistent changes.
- Steps:
  1. Verify `settings.json` contains `"tasks.Toast": true` and `locked.json` lists `"tasks.Toast"`.
  2. Attempt to toggle the value in UI → verify the UI rejects the change or if the control toggles, confirm `settings.json` still contains `"tasks.Toast": true` (no persistent change).
  3. Use the preference Reset action → verify no effect and `settings.json` still contains `"tasks.Toast": true` (value remains enforced by `locked.json`).

8. Property: `terminal.integrated.lineHeight` (locked-only)
- Expectation: This key is only present in `locked.json` (no user or default). The UI should show a `Managed` label and not allow a persistent override; behavior may be undefined depending on product implementation.
- Steps:
  1. Verify `locked.json` lists `"terminal.integrated.lineHeight"` and neither `settings.json` nor `default-settings.json` contain `"terminal.integrated.lineHeight"` (confirm `settings.json` does not contain the key).
  2. Confirm the UI shows `terminal.integrated.lineHeight` with a `Managed` or `Locked` indicator.
  3. Attempt to change the editor font size in the UI; verify the change is rejected or not persisted and that `settings.json` still does not contain `"terminal.integrated.lineHeight"`.
  4. Use the preference Reset action (if present) and verify there is no effect and `settings.json` remains without the key.

9. Property: `preferences.zoomLevel` (managed default only)
- Expectation: UI shows zoom level `0.5` initially (from managed defaults).
- Steps:
  1. Verify `default-settings.json` contains `"preferences.zoomLevel": 0.5` and `settings.json` does not contain an entry for `"preferences.zoomLevel"`.
  2. Change zoom in UI to `1.0` → verify `settings.json` now contains `"preferences.zoomLevel": 1.0` and the UI shows 1.0.
  3. Use the preference Reset action → verify the user entry is removed (confirm `settings.json` no longer contains `"preferences.zoomLevel"`) and the UI returns to `0.5` (effective value from `default-settings.json`).

10. Property: `preferences.ExitOnClose` (managed default + locked)
- Expectation: Managed default `false` is enforced and changes should be blocked.
- Steps:
  1. Verify `default-settings.json` contains `"preferences.ExitOnClose": false`, `locked.json` lists `"preferences.ExitOnClose"`, and `settings.json` does not contain `"preferences.ExitOnClose"`.
  2. Confirm UI reflects `ExitOnClose: false` and does not allow a persistent override.
  3. Attempt to change in UI → verify change is rejected and `settings.json` remains unchanged (confirm `settings.json` still does not contain `"preferences.ExitOnClose"`).

11. Property: `podman.system.connections.remote` (manual)
- Expectation: This is set manually during testing and should appear in `settings.json` when created.
- Steps:
  1. Create a remote connection via the Podman Desktop UI (or CLI) while running.
  2. Verify the connection appears under `podman.system.connections.remote` in `settings.json`.

12. Cleanup: remove or reset `settings.json`, `default-settings.json`, and `locked.json` as needed between runs.
