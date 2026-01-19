# GitHub Account Authentication (skeleton)

## Prerequisites

- Podman Desktop is installed
- The `ghcr.io/podman-desktop/podman-desktop-github-ext` extension is installed
- User has created a GitHub Personal Access Token (classic or fine-grained) with no extra permissions

## Steps

1. Open Podman Desktop and click the `Accounts` button in the navigation bar.
2. Click the `Sign in with GitHub authentication to use GitHub Account Authentication` button.

3. Branching scenario — choose either `Use Browser` or `Use PAT`.

### Use Browser

- A screen will appear that explains the browser/device flow and displays an auth code. Copy the auth code shown on that screen before proceeding.
- Click `Copy Link` and manually paste the link into a browser, or click `Yes` (if prompted) to open the browser automatically.
- In the browser: log in to GitHub if necessary, paste the sync/auth code when prompted, and authorize the device.
- After completing authorization, return to Podman Desktop.
- Click `Accounts` in the navbar — a new button should appear: `Sign out of GitHub authentication (<username>)` (where `<username>` is the authenticated GitHub username).

### Use PAT

- Selecting the PAT option opens an input window near the top of the Podman Desktop window titled `Authenticate to GitHub with Personal Access Token` with an `Enter PAT` field.
- Paste the previously-created Personal Access Token into the `Enter PAT` field and press Enter.
- The input window should disappear when the token is accepted.
- Click `Accounts` in the navbar — a new button should appear: `Sign out of GitHub authentication (<username>)` (where `<username>` is the account tied to the provided PAT).

## Expected results / verification

- Either flow results in an authenticated GitHub account visible via the Accounts UI.
- The `Sign out of GitHub authentication (<username>)` button appears in `Accounts` and shows the correct username.
- `Settings -> Authentication` contains `Github authentication` with status `LOGGED IN` and a log-out button contianing the correct username next to it
- For the PAT flow, ensure that no extra permissions are required and the token is accepted.
