# WF-05: Port Forwarding & Real Connectivity

This scenario verifies that port forwarding can be configured for both pods and services via the Dashboard, and that real HTTP connectivity is established and drops on removal.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply [v06-port-forwarding.yaml](resources/v06-port-forwarding.yaml). It creates pod `qe-v06-port` and service `qe-v06-port-svc` in namespace `qe-v06-workflows`.
  ```bash
  kubectl wait --for=condition=Ready pod/qe-v06-port -n qe-v06-workflows --timeout=60s
  ```

## Scenario Steps

### Forward a Pod

1. **Locate the Forward button**
   Select namespace `qe-v06-workflows`, then navigate to Pods → click `qe-v06-port` → open the **Summary** tab.
   **Expected:** A "Forward" button is visible in the Summary tab.

2. **Configure pod port forwarding**
   Click Forward; set local port 8888 and remote port 80; confirm.
   **Expected:** An entry appears in the Port Forwarding page: Name=`qe-v06-port`, Type=Pod, Local=8888, Remote=80.

3. **Verify real connectivity to the pod forward**
   ```bash
   curl localhost:8888
   ```
   **Expected:** HTTP 200 response. Body contains the Apache httpd welcome page.

### Forward a Service

4. **Configure service port forwarding**
   Navigate to Services → click `qe-v06-port-svc` → configure forwarding: local 8889 → remote 8080.
   **Expected:** A second entry appears in Port Forwarding: Name=`qe-v06-port-svc`, Type=Service, Local=8889, Remote=8080.

5. **Verify real connectivity to the service forward**
   ```bash
   curl localhost:8889
   ```
   **Expected:** HTTP 200 response.

### Verify Port Forwarding Page

6. **Check both entries on the Port Forwarding page**
   Navigate to the Port Forwarding page.
   **Expected:** Both entries are listed with correct Name, Type, Local Port, and Remote Port columns.

### Stop Forwarding & Verify Connection Drops

7. **Delete the pod port forward**
   Delete the `qe-v06-port` / 8888 entry via the Dashboard.
   **Expected:** The entry is removed from the Port Forwarding list.

8. **Verify the pod forward has stopped**
   ```bash
   curl localhost:8888
   ```
   **Expected:** `Connection refused` — forwarding has stopped.

9. **Delete the service port forward**
   Delete the remaining `qe-v06-port-svc` entry via the Dashboard.
   **Expected:** The Port Forwarding page shows an empty state ("No port forwarding configured" or similar).

## Cleanup

```bash
kubectl delete -f resources/v06-port-forwarding.yaml --ignore-not-found
```
