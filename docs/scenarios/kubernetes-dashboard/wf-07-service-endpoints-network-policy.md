# WF-07: Service, Endpoints & Network Policy

This scenario verifies Service detail views, live endpoint updates, EndpointSlice visibility, and Network Policy deletion via the Dashboard.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the network resources:
  ```bash
  kubectl apply -f resources/v06-network.yaml
  ```
  Resource file: [v06-network.yaml](resources/v06-network.yaml)

## Scenario Steps

### Service Details

1. **Open qe-v06-network-svc details**
   Select namespace `qe-v06-workflows`, then navigate to Services → click `qe-v06-network-svc`.
   **Expected:** The detail page shows Type=ClusterIP, a Cluster IP assigned, port 8080/TCP, and selector `app=qe-v06-network-web`.

### Endpoint Live Update

2. **Verify qe-v06-network-endpoint initial state**
   Navigate to Endpoints and verify `qe-v06-network-endpoint` shows address `10.0.0.1` and port `8080/TCP`.

3. **Patch qe-v06-network-endpoint to add a second address**
   ```bash
   kubectl patch endpoints qe-v06-network-endpoint -n qe-v06-workflows --type=json \
     -p='[{"op":"add","path":"/subsets/0/addresses/-","value":{"ip":"10.0.0.2"}}]'
   ```
   **Expected:** Navigating back to the Endpoints page (or refreshing) shows `qe-v06-network-endpoint` now lists both `10.0.0.1` and `10.0.0.2` in the Endpoints column.

4. **Verify EndpointSlice**
   Navigate to Endpoint Slices and verify `qe-v06-network-slice` shows Address Type=IPv4 and endpoint `10.0.0.1` as ready.

### Network Policy Delete via Dashboard

5. **Verify qe-v06-network-policy**
   Navigate to Network Policies and verify `qe-v06-network-policy` shows Policy Types=`Ingress, Egress` and Pod Selector=`app=qe-v06-network-web`.

6. **Delete qe-v06-network-policy via Dashboard**
   Use the delete action on `qe-v06-network-policy`.
   **Expected:** `qe-v06-network-policy` disappears from the Network Policies page. No error toast appears.

## Cleanup

```bash
kubectl delete -f resources/v06-network.yaml --ignore-not-found
```
