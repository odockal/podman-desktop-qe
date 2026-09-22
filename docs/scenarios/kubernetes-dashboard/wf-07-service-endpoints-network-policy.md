# WF-07: Service, Endpoints & Network Policy

This scenario verifies Service detail views, live endpoint updates, EndpointSlice visibility, and Network Policy deletion via the Dashboard.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the cluster resources:
  ```bash
  kubectl apply -f cluster-resources.yaml
  kubectl apply -f access-control.yaml
  ```
  Resource files:
  - [cluster-resources.yaml](resources/cluster-resources.yaml) — provides Services, Endpoints, NetworkPolicy
  - [access-control.yaml](resources/access-control.yaml) — provides EndpointSlice

## Scenario Steps

### Service Details

1. **Open svc1-clusterip details**  
   Navigate to Services → click `svc1-clusterip`.  
   **Expected:** The detail page shows Type=ClusterIP, a Cluster IP assigned, port 8080/TCP, and selector `app=svc1-clusterip`.

### Endpoint Live Update

2. **Verify endpoint1 initial state**  
   Navigate to Endpoints and verify `endpoint1` shows address `10.0.0.1` and port `8080/TCP`.

3. **Patch endpoint1 to add a second address**  
   ```bash
   kubectl patch endpoints endpoint1 --type=json \
     -p='[{"op":"add","path":"/subsets/0/addresses/-","value":{"ip":"10.0.0.2"}}]'
   ```
   **Expected:** Navigating back to the Endpoints page (or refreshing) shows `endpoint1` now lists both `10.0.0.1` and `10.0.0.2` in the Endpoints column.

4. **Verify EndpointSlice**  
   Navigate to Endpoint Slices and verify `test-endpointslice` shows Address Type=IPv4 and endpoint `10.0.0.1` as ready.

### Network Policy Delete via Dashboard

5. **Verify network-policy1**  
   Navigate to Network Policies and verify `network-policy1` shows Policy Types=`Ingress, Egress` and Pod Selector=`app=deploy1`.

6. **Delete network-policy1 via Dashboard**  
   Use the delete action on `network-policy1`.  
   **Expected:** `network-policy1` disappears from the Network Policies page. No error toast appears.
