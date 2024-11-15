# Extension installation test
This document covers how to complete the test cases from the first section of the `OpenShift Local extension` test sheet. In the first test case it is presumed that the `OpenShift Local extension` is not installed in the machine used.

### OSL extension installation from the PD catalog
Check the process on the [Extension installation section of the README](https://github.com/crc-org/crc-extension?tab=readme-ov-file#extension-installation)

### OSL extension installation via OCI URI - latest tag
Check the process on the [Extension installation section of the README](https://github.com/crc-org/crc-extension?tab=readme-ov-file#extension-installation)

### Dependency (on sso) is installed along with crc-ext
Once installed, go to the **Installed** section under the **Extensions** page and you should be able to find the `Red Hat OpenShift Local` and `Red Hat Authentication` extensions

### Extensions verification - enable, disable, remove
- Once installed, go to the **Installed** section under the **Extensions** page, and look for `Red Hat OpenShift Local`
- If the status of the extension is `ACTIVE`, disable it by clicking on the `Stop` button. Status should turn to `DISABLED`
- Enable the extension again by clicking on the `Start` button. Status should turn to `ACTIVE`
- Remove the extension by clicking on the `Stop` button and then on the `Delete` button. This should have the following effects:
	- The extension card disappears from the **Installed** section
	- The extension appears available again to be installed in the **Catalog** section
	- The extension card disappears from the **Settings/Resources** section
	- The extension card disappears from the **Settings/Preferences** section and from the navbar on the left
- Install the extension again for the next test cases

### Extensions verification - Settings/Resources provider card is present, contains buttons,etc
Go to **Settings/Resources** and find the `OpenShift Local` card, it should contain either:
- The `Start/Restart/Stop/Delete` buttons (if you have a crc instance), or
- The `Create new...` button to make a new instance (if you don't have any), or
- A text explaining what OpenShift Local is if you don't have crc installed

### Extensions verification - Settings/Preferences contains new record and property to configure
- Go to **Settings/Preferences** and find the `Red Hat OpenShift Local` entry, it should contain the `Preset` setting, and you should be able to change from `openshift` to `microshift` and vice versa
- Also a new entry (`Extension: Red Hat OpenShift Local`) should be available in the navbar on the left

### Extensions verification - Dashboard provider card is present, contains buttons,etc
Go to the **Dashboard** page and find the `OpenShift Local` card, it should contain either:
- The `RUNNING` label if you have a crc instance created and running, or
- The `Initialize and Start` or `Initialize` button if you don't have a crc instance, or
- The `NOT-INSTALLED` label, and the `View detection checks` and `Install` buttons (unless you're on Linux)