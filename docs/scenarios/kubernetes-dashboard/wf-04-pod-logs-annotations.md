# WF-04: Pod Logs & Annotation Features (New in 0.6.0)

This scenario verifies streaming pod logs and the dashboard-specific annotations for timestamps and colors.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Create a pod that produces continuous log output:
  ```bash
  kubectl run log-test --image=busybox -- sh -c "while true; do echo 'log line'; sleep 1; done"
  ```

## Scenario Steps

### Streaming

1. **Open the log-test pod logs**  
   Navigate to Pods → click `log-test` → open the **Logs** tab.  
   **Expected:** Log lines appear in the terminal. New lines (`log line`) appear approximately every second without any page reload.

### Timestamp Annotation

2. **Enable timestamp annotation**  
   Run:
   ```bash
   kubectl annotate pod log-test kubernetes-dashboard.podman-desktop.io/logs-timestamps=true
   ```
   **Expected:** Each subsequent log line in the Logs tab is prefixed with an ISO 8601 timestamp, e.g., `2026-09-15T12:00:01.000Z log line`.

### Color Annotation

3. **Enable color annotation**  
   Run:
   ```bash
   kubectl annotate pod log-test "kubernetes-dashboard.podman-desktop.io/logs-colors=colorizer 2"
   ```
   **Expected:** Log lines are rendered with distinct ANSI colors applied (each line is visually color-coded).

### Remove Annotations

4. **Remove both annotations**  
   Run:
   ```bash
   kubectl annotate pod log-test \
     kubernetes-dashboard.podman-desktop.io/logs-timestamps- \
     kubernetes-dashboard.podman-desktop.io/logs-colors-
   ```
   **Expected:** Log lines revert to plain format — no timestamp prefix, no colors.

## Cleanup

```bash
kubectl delete pod log-test
```
