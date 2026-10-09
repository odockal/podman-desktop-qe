# Kubernetes Contexts integration

This runbook validates the integration between the Kubernetes Dashboard and
Kubernetes Contexts extensions in Podman Desktop.

## Prerequisites

- Kubernetes Dashboard and Kubernetes Contexts extensions are enabled.
- A reachable Kubernetes context is configured.
- The dashboard is connected to that context.

## Context inventory and identity

1. Open **Contexts**.
2. Verify the active context is marked **Current Context** and **REACHABLE**.
3. Verify its name matches the Kubernetes context in the Podman Desktop status
   bar.
4. Verify the context card shows the cluster, server, user, pod count, and
   deployment count.

## Context selector

1. Click the Kubernetes context in the Podman Desktop status bar.
2. Verify the searchable selector opens and marks the active context.
3. Close the selector without changing the current context.

## Context management controls

1. Click **Import**. Verify a kubeconfig file path is required and **Import
   contexts** is disabled until one is selected. Cancel the dialog.
2. Duplicate the active context. Verify the duplicate has a suffixed name,
   starts in **UNKNOWN** state, and offers **Connect** and **Set as Current**.
3. Open **Edit Context** on the duplicate. Verify name, cluster, user, and
   namespace fields are available and **Save** is disabled without a change.
4. Cancel the edit dialog, then delete the duplicate context.

## Dashboard synchronization and recovery

1. Open **Kubernetes**. Verify the Dashboard is connected and displays the
   selected context's resource counts.
2. Disable Kubernetes Contexts while keeping Kubernetes Dashboard enabled.
   Expected behavior: Dashboard indicates that its context dependency is
   unavailable. Current behavior: it remains **Connected** but shows empty
   metrics; record this as a failure.
3. Re-enable Kubernetes Contexts. Verify the Contexts navigation entry returns
   and Dashboard resource counts recover without restarting Dashboard.
