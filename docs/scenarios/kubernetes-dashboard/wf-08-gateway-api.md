# WF-08: Gateway API (New in 0.6.0)

This scenario verifies that Gateway API resources (GatewayClass, Gateway, HTTPRoute) are visible in the Dashboard and can be deleted independently.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Install Gateway API CRDs before applying resources:
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
  ```
- Apply the Gateway API resources:
  ```bash
  kubectl apply -f resources/v06-gateway-api.yaml
  ```
  Resource file: [v06-gateway-api.yaml](resources/v06-gateway-api.yaml)

## Scenario Steps

1. **Verify GatewayClass**
   Navigate to Gateway Classes and verify `qe-v06-gateway-class` appears with Controller=`example.com/gateway-controller`.

2. **Verify Gateway**
   Select namespace `qe-v06-workflows`. Navigate to Gateways and verify `qe-v06-gateway` appears with Gateway Class=`qe-v06-gateway-class` and Listeners showing `http:80`.

3. **Verify HTTPRoute**
   Navigate to HTTPRoutes and verify `qe-v06-http-route` shows Parent Ref=`qe-v06-gateway` and Backend Ref=`qe-v06-gateway-svc:8080`.

4. **Open HTTPRoute details**
   Click on `qe-v06-http-route` to open its details.
   **Expected:** The rule shows PathPrefix `/` routing to backend `qe-v06-gateway-svc` port 8080.

5. **Delete qe-v06-http-route via Dashboard**
   Use the delete action on `qe-v06-http-route`.
   **Expected:** `qe-v06-http-route` disappears from HTTPRoutes. `qe-v06-gateway` is still present in Gateways.

6. **Delete qe-v06-gateway via Dashboard**
   Use the delete action on `qe-v06-gateway`.
   **Expected:** `qe-v06-gateway` disappears from Gateways. `qe-v06-gateway-class` is still present in Gateway Classes.

## Cleanup

```bash
kubectl delete -f resources/v06-gateway-api.yaml --ignore-not-found
```
