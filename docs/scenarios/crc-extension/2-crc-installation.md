# CRC installation
This document covers how to complete the test cases from the second section of the `OpenShift Local extension` test sheet. In the first test case it is presumed that the `OpenShift Local extension` is installed in the machine used but the `OpenShift Local` binaries are not.

You can find the process as well in the [OpenShift Local installation section from the README](https://github.com/crc-org/crc-extension?tab=readme-ov-file#openshift-local-installation).

### Can update crc - updates existing crc with the latest
- Download an older version of `crc`, you can find the different releases [here](https://github.com/crc-org/crc/releases)
- Install the downloaded version, the process varies depending on your OS
- Check that `crc` is correctly downloaded (`crc version` e.g.)
- On **Podman Desktop**, go to the **Dashboard** page and find the `OpenShift Local` card, it should contain a `Update to X.X.X` button (where X.X.X is the latest release)
- Click on it, a dialog should appear to confirm the update, click on the `Yes` button
- **Podman Desktop** should download the installer (you can check the progress on the download on the bottom) and open the installation wizard
- Follow the instructions on the wizard and after finishing the installation the `Update to X.X.X` button should've disappeared and you should have the newer version (check with `crc version`)
- Uninstall `crc` for the next test cases

### Can install crc - requirements check
Go to the **Dashboard** page, on the `OpenShift Local` card you will find an `Install` button (unless you're on Linux). Click on it, several green checks should appear

### Can install crc - crc binary installation
- A dialog to confirm the `crc` installation should've appeared, click on the `Yes` button
- **Podman Desktop** should download the installer (check the progress on the download on the bottom) and open the installation wizard.
- Follow the instructions on the wizard and after finishing the installation a dialog that prompts you to restart the computer should appear. Click on `Restart`.
- Open **Podman Desktop** when the computer finishes restarting, on the **Dashboard** you should find that the `OpenShift Local` card has a version label and an `INSTALLED BUT NOT READY` status

### Can install crc - openshift bundle downloaded
During the cluster initialization process, if you didn't have the openshift bundle on your machine and you had the `openshift` preset, you should've spotted its download in the bottom of the Podman Desktop UI

### Can install crc - preset dialog offered
On the **Dashboard**, click on the `Initialize and start` button, a dialog that prompts you to choose a preset should appear

### Can install crc - crc binary installed - task manager check
Once `crc` has been initialized and started, open the **Task Manager**. A process called `crc.exe` should be running

