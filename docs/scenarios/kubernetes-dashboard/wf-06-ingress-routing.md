# WF-06: Ingress Routing — End-to-End HTTP

This scenario verifies that Ingress resources are visible in the Dashboard and that HTTP routing through the ingress controller works end-to-end, including verification that traffic stops after ingress deletion.

## Prerequisites

- Kind cluster with NGINX ingress controller installed and NodePort accessible at `localhost:9090`.
- Apply the test resources:
  ```bash
  kubectl apply -f - <<'EOF'
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: hello-app
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: hello
    template:
      metadata:
        labels:
          app: hello
      spec:
        containers:
        - name: hello
          image: nginx:stable
          ports:
          - containerPort: 80
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: hello-svc
  spec:
    selector:
      app: hello
    ports:
    - port: 80
  ---
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: hello-ingress
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
  spec:
    ingressClassName: nginx
    rules:
    - http:
        paths:
        - path: /hello
          pathType: Prefix
          backend:
            service:
              name: hello-svc
              port:
                number: 80
  EOF
  ```

## Scenario Steps

1. **Verify hello-app deployment is running**  
   Navigate to Deployments and verify `hello-app` appears and reaches Running (1/1).

2. **Verify hello-svc service**  
   Navigate to Services and verify `hello-svc` appears with correct Type (ClusterIP) and port 80.

3. **Verify hello-ingress in the Dashboard**  
   Navigate to Ingresses & Routes and verify `hello-ingress` appears with path `/hello` and backend `hello-svc:80`.

4. **Verify real HTTP routing**  
   ```bash
   curl localhost:9090/hello
   ```
   **Expected:** HTTP 200 response. Body contains the nginx welcome page.

5. **Delete hello-ingress via Dashboard**  
   On the Ingresses & Routes page, use the delete action on `hello-ingress`.  
   **Expected:** `hello-ingress` disappears from the Ingresses & Routes page.

6. **Verify the route is gone**  
   ```bash
   curl localhost:9090/hello
   ```
   **Expected:** HTTP 404 or `Connection refused` — the ingress rule has been removed and traffic is no longer routed.

## Cleanup

```bash
kubectl delete deployment hello-app
kubectl delete service hello-svc
```
