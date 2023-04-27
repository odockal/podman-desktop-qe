# Windows Podman Desktop and Podman Clean up Procedures

* You can do some clean up using Podman Desktop, but it is not necessary

0. Prune all pods, containers and images (podman desktop or podman)
1. Close Podman Desktop and close the tray - quit the app
2. Uninstall Podman Desktop from Programs (if installed from msi/setup)
3. In powershell for all machines: `podman machine stop`, `podman machine rm -f`
4. To clean up podman desktop resources: `~/.local/share/containers/podman-desktop/`, `~/.local/share/podman-desktop/`,`~/AppData/Roaming/Podman Desktop`
5. WSL distribution removal - `wsl --unregister` - reset Linux instance
Removing WSL distros - winget, wsl.exe --unregister (resets the distro)
* `winget uninstall --id Canonical.Ubuntu`
* `wsl --list`
* `wsl --unregister Ubuntu`
* `wslconfig /l - list, /s - setdefault, /t - terminate, /u - unregister`
6. WSL uninstallation
7. Turning off windows features: HyperV, WSL, Virtual Machine Platform - if needed.
* `Get-WindowsOptionalFeature -Online` - to list all available Windows Features, presents list with `FeatureName` and `State`
* `Get-WindowsOptionalFeature -Online -FeatureName '*linux*' | Select-Object FeatureName` - to list all available Windows Features that contains `linux` string and then shows only `FeatureName` property of the object
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart`
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart`
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart`
8. Podman Uninstallation 
* msi package could be uninstalled:
* `Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x <ProductCode> /qn /l*v <path to the log file" -Wait`
* Or uninstallation done via powershell
* `$app = Get-WmiObject -Class Win32_Product -Filter "Name = '<ProductName>'"`
* `$app.Uninstall()`
*