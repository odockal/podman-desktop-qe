# Testing Documentation: Network Management Feature

**Feature Epic:** [#11630 - Network tab](https://github.com/podman-desktop/podman-desktop/issues/11630)

**Objective:** To provide users with a graphical interface within Podman Desktop to view, create, inspect, and delete container networks. This feature aims to replicate core podman network CLI functionality in a user-friendly way.

---

## 1. Test Cases for Network List View

**Issue:** [#14109](https://github.com/podman-desktop/podman-desktop/issues/14109)

**Objective:** The Network List View is the main dashboard for network management. It should display all available networks and provide primary actions for management.

### UI Elements to Verify

- A new top-level menu item labeled "Networks" is present in the main navigation sidebar.
- The Networks page displays a table or list of all container networks.
- The list includes the following columns:
  - Network ID
  - Name
  - Driver
  - Actions
- Each item in the list has an "Actions" menu (e.g., a kebab menu icon).
- The "Actions" menu for each network contains options for "Update" and "Delete".

### Functional Test Cases

#### Navigation

- Verify that clicking the "Networks" menu item navigates the user to the network list page.

#### Data Display

- Verify that the list accurately populates with all networks currently available to the active container engine.
- Verify that the Network ID, Name, and Driver values are correct for each network listed.
- **Edge Case:** Verify that if no networks exist, the page displays a clear "empty state" message, possibly with a shortcut to create a new network.

#### Actions

- Verify that clicking the "Delete" action for a network prompts the user for confirmation.
- Upon confirmation, verify the network is deleted and removed from the list.
- Verify that the "Update" action navigates the user to an editing view for that network (details of this view may be covered in other tasks).

---

## 2. Test Cases for Network Detail View

**Issue:** [#14110](https://github.com/podman-desktop/podman-desktop/issues/14110)

**Objective:** To provide a detailed, read-only view of a selected network's configuration and properties.

### UI Elements to Verify

- The detail view page is accessible by clicking on a network from the list view.
- The page layout contains two distinct tabs: "Summary" and "Inspect".
- The "Summary" tab is the default view.

### Functional Test Cases

#### Navigation

- Verify that clicking a network's name or ID in the list view navigates to its corresponding detail page.

#### Summary Tab

- Verify the "Summary" tab displays key-value pairs of the most important network properties (e.g., Name, ID, Driver, Subnet, Gateway).
- Verify the information displayed is accurate for the selected network.

#### Inspect Tab

- Verify that clicking the "Inspect" tab switches the view.
- Verify the "Inspect" tab displays the full, raw JSON output equivalent to running `podman network inspect <network-name-or-id>` in the terminal.
- Verify the JSON content is correctly formatted and complete.

---

## 3. Test Cases for Create Network Flow

**Issue:** [#14111](https://github.com/podman-desktop/podman-desktop/issues/14111)

**Objective:** To allow users to create a new container network using a form.

### UI Elements to Verify

- A prominent "Create" button is visible on the Network List View page.
- Clicking "Create" opens a new page or modal with a form for network creation.
- The form contains the following fields, with specified types and constraints:

| Field | Type | Notes |
|-------|------|-------|
| Name | Text | Required |
| Label | Text | |
| Interface name | Text | |
| Container engine | Dropdown | |
| Subnet | Text | |
| IPv6 | Toggle | Default: OFF |
| IP range | Text | |
| Gateway | Text | |
| Internal | Toggle | Default: OFF |
| Driver | Dropdown | Default: bridge |
| Disable DNS | Checkbox | Default: OFF |
| DNS | Text | Disabled if "Disable DNS" is checked |
| opt | Text | |

- The form has two action buttons: "Create" and "Cancel".

### Functional Test Cases

#### Form Validation

- Verify the "Create" button is disabled until all required fields (i.e., Name) are filled.
- Verify the DNS input field is disabled when the "Disable DNS" checkbox is ticked and enabled when it is unticked.

#### Creation Flow (Happy Path)

- Fill in the required fields and reasonable optional values.
- Click the "Create" button.
- Verify the network is successfully created.
- Verify the user is redirected back to the Network List View.
- Verify the newly created network appears in the list with the correct configuration.

#### Cancellation

- Fill the form with some data.
- Click the "Cancel" button.
- Verify the user is returned to the Network List View and no new network was created.

