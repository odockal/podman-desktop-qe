# Windows Podman Desktop, Kind and Podman Clean up Procedures

## Kind clean up
1. Clean up running containers and pulled images - in case of kind, one can use UI to delete kind cluster, or run `kind delete clusters --all`
2. Depending on what we tweaked along the way, we need to revert (/docs/scenarios/kind/kind-testing-scenarios.md)
* setting up kind to be run as rootless
* using rootless or rootful podman on the system
3. Remove Kind binary
* System wide installation: Search on path
* Podman Desktop installed binary: `/home/user/.local/share/containers/podman-desktop/extensions-storage/kind`
4. Remove Minikube
* `minikube delete`
* `rm -rf ~/.minikube`

## Podman Uninstallation process using various methods

### Podman Resources (containers, pods, images, machines) removal

0. Prune all pods, containers and images (podman desktop or podman) - removing the podman machine removes also all of those
1. Close Podman Desktop and close the tray - quit the app
2. In powershell for all machines: `podman machine stop`, `podman machine rm -f`
3. You can also reset podman machine: `podman machine reset -f`
4. Beware that all of the command above works for default provider (wsl), if you make sure to remove all, set `$env:CONTAINERS_MACHINE_PROVIDER='wsl' ('hyperv')` and run the commands
5. HyperV requires powershell/cli to be run as admin
6. Clean up possible leftovers from WSL or HyperV
* `wsl --list`
* To remove User mode networking machine - `wsl --unregister podman-net-usermode`
* Open HyperV manager and make sure to remove the machine if still present

## Podman Uninstallation process
1. Open Programs and uninstall Podman
2. Powershell approach
* msi package could be uninstalled:
* `Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x <ProductCode> /qn /l*v <path to the log file" -Wait`
* Or uninstallation done via powershell
* `$app = Get-WmiObject -Class Win32_Product -Filter "Name = '<ProductName>'"`
* `$app.Uninstall()`
3. Remove files and configurations, leftovers, might differ
```
~/.local/share/containers/* (podman, storage, etc.)
~/.config/containers/
~/AppData/Roaming/containers
~/.ssh/podman-machine* # depends on machine name
C:\Program Files\RedHat\Podman # just mentioning the default installation location when installed from msi
```
* Some paths may vary depending on installer/podman version used

## Podman Desktop Uninstallation

1. Uninstall Podman Desktop from Programs (if installed from setup) - UI
2. Other methods depends on how podman-desktop was installed - winget, scoop, chocolatey
3. Using powershell cli
* msi package could be uninstalled:
* `Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x <ProductCode> /qn /l*v <path to the log file" -Wait`
* Or uninstallation is done via powershell
* `$app = Get-WmiObject -Class Win32_Product -Filter "Name = '<ProductName>'"`
* `$app.Uninstall()`
4. To clean up podman desktop home configuration files:
* `~/.local/share/containers/podman-desktop/` # settings, extensions, etc.
* `~/AppData/Roaming/Podman Desktop` # tmp files storage, caches, blobs, etc.
* `~/AppData/Local/podman-desktop-updater` # appears after podman-desktop update
* `~/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/podman-desktop.vbs` # start up script

## Disabling Windows Features

1. Disabling HyperV, WSL, Virtual Machine Platform - if needed.
2. Open "Turn Windows Features On/Off" app and uncheck required features - restart computer
3. Turning off windows features using powershell
* `Get-WindowsOptionalFeature -Online` - to list all available Windows Features, presents list with `FeatureName` and `State`
* `Get-WindowsOptionalFeature -Online -FeatureName '*linux*' | Select-Object FeatureName` - to list all available Windows Features that contains `linux` string and then shows only `FeatureName` property of the object
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart`
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart`
* `Disable(Enable)-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart`
4. Restart computer to changes to take effect
