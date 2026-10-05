# WF-06: Ingress Routing — End-to-End HTTP

This scenario verifies that Ingress resources are visible in the Dashboard and that HTTP routing through the ingress controller works end-to-end, including verification that traffic stops after ingress deletion.

## Prerequisites

- Kind cluster with NGINX ingress controller installed and NodePort accessible at `localhost:9090`.
- Apply [v06-ingress.yaml](resources/v06-ingress.yaml). It creates `qe-v06-hello`, `qe-v06-hello-svc`, and `qe-v06-hello-ingress` in namespace `qe-v06-workflows`.

## Scenario Steps

1. **Verify qe-v06-hello deployment is running**
   Select namespace `qe-v06-workflows`. Navigate to Deployments and verify `qe-v06-hello` appears and reaches Running (1/1).

2. **Verify qe-v06-hello-svc service**
   Navigate to Services and verify `qe-v06-hello-svc` appears with correct Type (ClusterIP) and port 80.

3. **Verify qe-v06-hello-ingress in the Dashboard**
   Navigate to Ingresses & Routes and verify `qe-v06-hello-ingress` appears with path `/hello` and backend `qe-v06-hello-svc:80`.

4. **Verify real HTTP routing**
   ```bash
   curl localhost:9090/hello
   ```
   **Expected:** HTTP 200 response. Body contains the nginx welcome page.

5. **Delete qe-v06-hello-ingress via Dashboard**
   On the Ingresses & Routes page, use the delete action on `qe-v06-hello-ingress`.
   **Expected:** `qe-v06-hello-ingress` disappears from the Ingresses & Routes page.

6. **Verify the route is gone**
   ```bash
   curl localhost:9090/hello
   ```
   **Expected:** HTTP 404 or `Connection refused` — the ingress rule has been removed and traffic is no longer routed.

## Cleanup

```bash
kubectl delete -f resources/v06-ingress.yaml --ignore-not-found
```
