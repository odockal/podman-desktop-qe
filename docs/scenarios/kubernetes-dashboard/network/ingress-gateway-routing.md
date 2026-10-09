# Ingress and Gateway API routing

## Purpose

Verify that Podman Desktop shows and updates the complete HTTP routing path:

```text
request → Ingress or Gateway/HTTPRoute → Service → web Pods
```

The test uses one backend, `test-routing-service:8080`.

- **IngressClass** selects the Ingress controller.
- **Ingress** sends a host and path to the Service.
- **GatewayClass** selects the Gateway API controller.
- **Gateway** opens the HTTP listener.
- **HTTPRoute** sends matching requests from that listener to the Service.

## One-time kind setup

This workflow uses [Contour](https://projectcontour.io/) and Envoy. Contour
implements both Ingress and Gateway API. On kind, Envoy has no external address,
so use a temporary port-forward for HTTP checks.

Install Contour only if `projectcontour` does not already exist:

```sh
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl -n projectcontour rollout status deployment/contour --timeout=120s
```

Apply this once as `contour-routing.yaml`. It creates the IngressClass and
enables Contour to manage the `projectcontour/contour` Gateway. If the existing
`contour.yaml` has other settings, keep them and add only `gateway.gatewayRef`.

```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: contour
spec:
  controller: projectcontour.io/ingress-controller
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: contour
  namespace: projectcontour
data:
  contour.yaml: |
    gateway:
      gatewayRef:
        name: contour
        namespace: projectcontour
    disablePermitInsecure: false
    accesslog-format: envoy
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: contour
spec:
  controllerName: projectcontour.io/gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: contour
  namespace: projectcontour
spec:
  gatewayClassName: contour
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All
```

```sh
kubectl apply -f contour-routing.yaml
kubectl -n projectcontour rollout restart deployment/contour
kubectl -n projectcontour rollout status deployment/contour --timeout=120s
```

Before any HTTP check, run this in a separate terminal:

```sh
kubectl port-forward -n projectcontour service/envoy 18080:80
```

## Test fixture

Apply this YAML through **Network → Apply YAML** or with `kubectl apply -f`.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-network-routing
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-routing-web
  namespace: test-network-routing
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-routing-web
  template:
    metadata:
      labels:
        app: test-routing-web
    spec:
      containers:
        - name: web
          image: registry.access.redhat.com/ubi9/python-312:latest
          command: ["python", "-m", "http.server", "8080"]
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: test-routing-service
  namespace: test-network-routing
spec:
  selector:
    app: test-routing-web
  ports:
    - name: http
      port: 8080
      targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-routing-ingress
  namespace: test-network-routing
spec:
  ingressClassName: contour
  rules:
    - host: test-routing.example.invalid
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: test-routing-service
                port:
                  number: 8080
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: test-routing-route
  namespace: test-network-routing
spec:
  parentRefs:
    - name: contour
      namespace: projectcontour
      sectionName: http
  hostnames:
    - test-gateway.example.invalid
  rules:
    - backendRefs:
        - name: test-routing-service
          port: 8080
```

## Checks in Podman Desktop

### 1. Ingress

1. In **Network → Ingress Classes**, verify `contour` is listed.
2. In **Network → Ingresses & Routes**, select `test-network-routing` and
   verify `test-routing-ingress` points to `test-routing-service:8080`.
3. Request the Ingress host. Expect HTTP 200:

   ```sh
   curl --fail --silent --show-error \
     --resolve test-routing.example.invalid:18080:127.0.0.1 \
     http://test-routing.example.invalid:18080/
   ```

4. In the Ingress **Patch** tab, temporarily set the backend Service to a
   nonexistent name. The request must stop returning HTTP 200. Restore
   `test-routing-service:8080`; HTTP 200 must return.

### 2. Gateway API

1. In **Network → Gateway Classes**, verify `contour` is listed.
2. In **Network → Gateways**, select `projectcontour` and verify `contour` is
   Running with listener `http:80/HTTP`.
3. In **Network → HTTPRoutes**, select `test-network-routing` and verify
   `test-routing-route` has parent `contour` and backend
   `test-routing-service:8080`.
4. Request the route host. Expect HTTP 200:

   ```sh
   curl --fail --silent --show-error \
     --resolve test-gateway.example.invalid:18080:127.0.0.1 \
     http://test-gateway.example.invalid:18080/
   ```

## Cleanup

```sh
kubectl delete namespace test-network-routing --ignore-not-found
```
