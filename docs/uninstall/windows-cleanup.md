# Windows Podman Desktop, Kind and Podman Clean up Procedures

## Kind clean up
1. Clean up running containers and pulled images - in case of kind, one can use UI to delete kind cluster, or run `kind delete clusters --all`
2. Depending on what we tweaked along the way, we need to revert (/docs/scenarios/kind/kind-testing-scenarios.md)
* setting up kind to be run as rootless
* using rootless or rootful podman on the system
3. Remove Kind binary
* System wide installation: Search on path
* Podman Desktop installed binary: `/home/user/.local/share/containers/podman-desktop/extensions-storage/kind`

## Podman Uninstallation

0. Prune all pods, containers and images (podman desktop or podman)
1. Close Podman Desktop and close the tray - quit the app
2. In powershell for all machines: `podman machine stop`, `podman machine rm -f`
3. WSL distribution removal - `wsl --unregister` - reset Linux instance
Removing WSL distros - winget, wsl.exe --unregister (resets the distro)
* `winget uninstall --id Canonical.Ubuntu`
* `wsl --list`
* `wsl --unregister Ubuntu`
* `wslconfig /l - list, /s - setdefault, /t - terminate, /u - unregister`
4. WSL uninstallation
5. Turning off windows features: HyperV, WSL, Virtual Machine Platform - if needed.
* `Get-WindowsOptionalFeature -Online` - to list all available Windows Features, presents list with `FeatureName` and `State`
* `Get-WindowsOptionalFeature -Online -FeatureName '*linux*' | Select-Object FeatureName` - to list all available Windows Features that contains `linux` string and then shows only `FeatureName` property of the object
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart`
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart`
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart`
6. Podman Uninstallation 
* msi package could be uninstalled:
* `Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x <ProductCode> /qn /l*v <path to the log file" -Wait`
* Or uninstallation done via powershell
* `$app = Get-WmiObject -Class Win32_Product -Filter "Name = '<ProductName>'"`
* `$app.Uninstall()`

## Podman Desktop Uninstallation
1. Uninstall Podman Desktop from Programs (if installed from msi/setup) - UI
2. Using powershell/cmd
* msi package could be uninstalled:
* `Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x <ProductCode> /qn /l*v <path to the log file" -Wait`
* Or uninstallation is done via powershell
* `$app = Get-WmiObject -Class Win32_Product -Filter "Name = '<ProductName>'"`
* `$app.Uninstall()`
3. To clean up podman desktop resources: `~/.local/share/containers/podman-desktop/`, `~/.local/share/podman-desktop/`,`~/AppData/Roaming/Podman Desktop`