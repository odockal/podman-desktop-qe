# Extension installation test
This document covers how to complete the test cases from the first section of the `MINC extension` test sheet. In the first test case it is presumed that the `MINC extension` is not installed in the machine used and that Podman Desktop is open. Version of the extension used for the purposes of this document: `0.4.0`.

### OSL extension installation from the PD catalog
1. Go to the **Extensions** page:
2. Switch to the **Catalog** tab and click on the `Install` icon in the `MINC` extension item

### OSL extension installation via OCI URI - latest tag
1. Go to the **Extensions** page:
2. Click on the `Install custom...` button on the upper right corner, enter `ghcr.io/minc-org/minc-extension` in the `OCI Image` field, and click on `Install`. This second approach is useful to get older versions or development releases (use `:next` tag).

### Extension verification - enable, disable, remove
- Once installed, go to the **Installed** section under the **Extensions** page, and look for `MicroShift extension`
- The status of the extension should be `ACTIVE`, disable it by clicking on the `Stop` button. Status should turn to `DISABLED`
- Enable the extension again by clicking on the `Start` button. Status should turn to `ACTIVE`
- Remove the extension by clicking on the `Stop` button and then on the `Delete` button. This should have the following effects:
	- The extension card disappears from the **Installed** section
	- The extension appears available again to be installed in the **Catalog** section
	- The extension card disappears from the **Settings/Resources** section
- Install the extension again for the next test cases

### Extension verification - Settings/Resources provider card is present, contains buttons, etc
Go to **Settings/Resources** and find the `MicroShift` card, it should contain:
- The `Create new...` button to make a new instance,
- A text explaining what MINC is (if you don't have a cluster created),
- The cluster name, status, and `Start/Restart/Stop/Delete` buttons (if you have a cluster created)


