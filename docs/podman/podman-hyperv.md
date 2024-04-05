# Podman Using HyperV hypervisor as a Container Machine provider on Windows OS

# Podman 4.8.0 support for Hyper V

## Active usage of HyperV machine provider

In order to tell podman to use hyperv when creating a podman machine, one needs to setup either:
* environment variable: `CONTAINERS_MACHINE_PROVIDER=hyperv` on the terminal session or as system env. var.
OR
* configure container.conf file attribute provider before creating a machine, the file might be placed at `~/.config/containers/containers.conf` (not supported atm) or under `AppData`: `C:\Users\myuser\AppData\Roaming\containers\containers.conf`
```powershell
cat C:\Users\myuser\AppData\Roaming\containers\containers.conf
[machine]

provider = "hyperv"
memory = 4096
...
```

Succesfull setup should show string like this in the start up log:
```
time="2023-05-09T21:16:08+03:00" level=debug msg="Using Podman machine with `hyperv` virtualization provider"
```

Full example then could looks like this, open powershell with admin provileges:
```
PS C:\Windows\system32> $env:ACONTAINERS_MACHINE_PROVIDER = 'hyperv'
PS C:\Windows\system32> $env:CONTAINERS_MACHINE_PROVIDER
hyperv

# or alternatively
# [System.Environment]::SetEnvironmentVariable('CONTAINERS_MACHINE_PROVIDER','hyperv')
# [System.Environment]::GetEnvironmentVariable('CONTAINERS_MACHINE_PROVIDER)

podman machin init
podman machine start
```

Since [Podman 4.8.0](https://github.com/containers/podman/releases/tag/v4.8.0), there is included support for HyperV hypervisor.
The feature was added with 
