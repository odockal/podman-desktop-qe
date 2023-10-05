PS C:\Users\podmanqe> irm get.scoop.sh | iex
Initializing...
PowerShell requires an execution policy in [Unrestricted, RemoteSigned, ByPass] to run Scoop. For example, to set the execution policy to 'RemoteSigned' please run 'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser'.
Abort.
PS C:\Users\podmanqe> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Execution Policy Change
The execution policy helps protect you from scripts that you do not trust. Changing the execution policy might expose
you to the security risks described in the about_Execution_Policies help topic at
https:/go.microsoft.com/fwlink/?LinkID=135170. Do you want to change the execution policy?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"): Y
PS C:\Users\podmanqe> irm get.scoop.sh | iex
Initializing...
Downloading ...
Creating shim...
Adding ~\scoop\shims to your path.
Scoop was installed successfully!
Type 'scoop help' for instructions.
PS C:\Users\podmanqe> scoop bucket add extras
Checking repo... OK
The extras bucket was added successfully.
PS C:\Users\podmanqe> scoop bucket add extras
>> scoop install podman-desktop
WARN  The 'extras' bucket already exists. To add this bucket again, first remove it by running 'scoop bucket rm extras'.
Installing '7zip' (23.01) [64bit] from main bucket
7z2301-x64.msi (1.8 MB) [=====================================================================================] 100%
Checking hash of 7z2301-x64.msi ... ok.
Extracting 7z2301-x64.msi ... done.
Linking ~\scoop\apps\7zip\current => ~\scoop\apps\7zip\23.01
Creating shim for '7z'.
Creating shim for '7zFM'.
Creating shim for '7zG'.
Creating shortcut for 7-Zip (7zFM.exe)
Persisting Codecs
Persisting Formats
Running post_install script...
'7zip' (23.01) was installed successfully!
Notes
-----
Add 7-Zip as a context menu option by running: "C:\Users\podmanqe\scoop\apps\7zip\current\install-context.reg"
Installing 'podman-desktop' (1.4.0) [64bit] from extras bucket
podman-desktop-1.4.0.exe (229.6 MB) [=========================================================================] 100%
Checking hash of podman-desktop-1.4.0.exe ... ok.
Extracting dl.7z ... done.
Running pre_install script...
Linking ~\scoop\apps\podman-desktop\current => ~\scoop\apps\podman-desktop\1.4.0
Creating shortcut for Podman Desktop (Podman Desktop.exe)
'podman-desktop' (1.4.0) was installed successfully!
