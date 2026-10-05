# WF-04: Pod Logs & Annotation Features (New in 0.6.0)

This scenario verifies streaming pod logs and the dashboard-specific annotations for timestamps and colors.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply [v06-logs.yaml](resources/v06-logs.yaml). It creates pod `qe-v06-logs` in namespace `qe-v06-workflows`.

## Scenario Steps

### Streaming

1. **Open the qe-v06-logs pod logs**
   Select namespace `qe-v06-workflows`, then navigate to Pods → click `qe-v06-logs` → open the **Logs** tab.
   **Expected:** Log lines appear in the terminal. New lines (`log line`) appear approximately every second without any page reload.

### Timestamp Annotation

2. **Enable timestamp annotation**
   Run:
   ```bash
   kubectl annotate pod qe-v06-logs -n qe-v06-workflows kubernetes-dashboard.podman-desktop.io/logs-timestamps=true
   ```
   **Expected:** Each subsequent log line in the Logs tab is prefixed with an ISO 8601 timestamp, e.g., `2026-09-15T12:00:01.000Z log line`.

### Color Annotation

3. **Enable color annotation**
   Run:
   ```bash
   kubectl annotate pod qe-v06-logs -n qe-v06-workflows "kubernetes-dashboard.podman-desktop.io/logs-colors=colorizer 2"
   ```
   **Expected:** Log lines are rendered with distinct ANSI colors applied (each line is visually color-coded).

### Remove Annotations

4. **Remove both annotations**
   Run:
   ```bash
   kubectl annotate pod qe-v06-logs -n qe-v06-workflows \
     kubernetes-dashboard.podman-desktop.io/logs-timestamps- \
     kubernetes-dashboard.podman-desktop.io/logs-colors-
   ```
   **Expected:** Log lines revert to plain format — no timestamp prefix, no colors.

## Cleanup

```bash
kubectl delete -f resources/v06-logs.yaml --ignore-not-found
```
