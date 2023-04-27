# Podman Desktop installation on Windows
## Topics
- Building from source
    - Headless and restricted environment installation
    - Portable executable
- Silent/Headless installation
- Airgapped/Restricted environment installation
- Portable executable
- Chocolatey installation
- Scoop installation
- Winget installation

## Building from source
1. Requirements
    - node.js >=v16.3 installed
    - npm >= 8.1 installed
2. Compilation process
```
$ git clone https://github.com/containers/podman-desktop.git
$ cd podman-desktop
$ npm install
$ npm run compile:current
```
### Headless and restricted environment installation
```
$ Start-Process -FilePath '.\dist\podman-desktop-0.15.0-next-setup.exe' -ArgumentList "\S" -Wait
```
No console output, terminal starts the installation in a separate window, after successfull installation Podman Desktop app launches.
### Portable executable
```
$ .\dist\win-unpacked\"Podman Desktop.exe"
or
$ .\dist\podman-desktop-0.15.0-next.exe
```

## Silent/Headless installation
1. Requirements
    - Podman Desktop Windows installer downloaded (https://podman-desktop.io/downloads/windows)
2. Installation process
```
$ Start-Process -FilePath '.\podman-desktop-0.13.0-setup.exe' -ArgumentList "\S" -Wait
```
No console output, terminal starts the installation in a separate window, after successfull installation Podman Desktop app launches.

## Airgapped/Restricted environment installation
1. Requirements 
    - Linux WSL installed (not required for only testing the installation)
    - Windows installer for restricted environments downloaded (https://podman-desktop.io/downloads/windows)

2. Installation process => Same as headless.

## Portable executable
1. Requirements 
    - Podman Desktop Windows portable executable downloaded (https://podman-desktop.io/downloads)

2. Launch
```
$ cd folder_with_the_executable
$ podman-desktop-0.13.0.exe
```

## Chocolatey installation
1. Requirements
    - Chocolatey package manager installed (https://chocolatey.org/install)

2. Installation process
```
$ choco install podman-desktop 
```

## Scoop installation
1. Requirements
    - Scoop package manager installed (https://github.com/ScoopInstaller/Install#readme)

2. Installation process
```
$ scoop bucket add extras
$ scoop install podman-desktop
```

## Winget installation
1. Requirements
    - Winget Package manager for Windows installed (Winget command-line tool is available on Win11 and modern versions of Win10 as a part of the App Installer. With older Win versions use:
https://aka.ms/getwinget)

2. Installation process
```
$ winget install -e --id RedHat.Podman-Desktop
```
The first time any winget installation is ran on a machine, the user is asked to agree to source agreements terms (_[Y] Yes [N] No_).
