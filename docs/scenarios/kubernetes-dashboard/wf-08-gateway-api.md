# WF-08: Gateway API (New in 0.6.0)

This scenario verifies that Gateway API resources (GatewayClass, Gateway, HTTPRoute) are visible in the Dashboard and can be deleted independently.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Install Gateway API CRDs before applying resources:
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
  ```
- Apply the cluster resources:
  ```bash
  kubectl apply -f cluster-resources.yaml
  ```
  Resource file: [cluster-resources.yaml](resources/cluster-resources.yaml)

## Scenario Steps

1. **Verify GatewayClass**  
   Navigate to Gateway Classes and verify `gateway-class1` appears with Controller=`example.com/gateway-controller`.

2. **Verify Gateway**  
   Navigate to Gateways and verify `gateway1` appears with Gateway Class=`gateway-class1` and Listeners showing `http:80`.

3. **Verify HTTPRoute**  
   Navigate to HTTPRoutes and verify `httproute1` shows Hostnames=`example.com`, Parent Refs=`gateway1`, and Backend Refs=`svc1-clusterip:8080`.

4. **Open HTTPRoute details**  
   Click on `httproute1` to open its details.  
   **Expected:** The rule shows PathPrefix `/` routing to backend `svc1-clusterip` port 8080.

5. **Delete httproute1 via Dashboard**  
   Use the delete action on `httproute1`.  
   **Expected:** `httproute1` disappears from HTTPRoutes. `gateway1` is still present in Gateways.

6. **Delete gateway1 via Dashboard**  
   Use the delete action on `gateway1`.  
   **Expected:** `gateway1` disappears from Gateways. `gateway-class1` is still present in Gateway Classes.
