# Ingress and Gateway API lifecycle

## Goal

Verify that the Network section exposes the routing resources installed in the
cluster, relates an Ingress to a Service backend, and shows Gateway API
resources only when their APIs and controller are available.

## Prerequisites

- Connected cluster and permission to create and list resources in an isolated
  namespace.
- For the Ingress traffic check: an installed Ingress controller and a usable
  `IngressClass`.
- For Gateway API checks: `gateway.networking.k8s.io` CRDs, a GatewayClass, and
  a controller that programs Gateways and HTTPRoutes.
- For OpenShift Route checks: the OpenShift Route API and a Route-capable
  cluster. Otherwise, record Route coverage as not applicable.

Do not mark a missing API, controller, or RBAC-denied page as a product
failure. Record it as a prerequisite gate. A page that is available but fails
to list an applied resource is a failure.

## Setup

Apply this YAML with **Network → Apply YAML** or `kubectl apply -f -`:

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
  ingressClassName: REPLACE_WITH_INSTALLED_INGRESS_CLASS
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
```

Replace `REPLACE_WITH_INSTALLED_INGRESS_CLASS` before applying. If no class is
installed, apply only the Namespace, Deployment, and Service and keep the
Ingress portion as blocked by the prerequisite.

## Dashboard workflow

1. Select `test-network-routing`. In **Network → Services**, verify
   `test-routing-service` has its selector and port. In **Endpoints** and
   **Endpoint Slices**, verify two ready backends.
2. Open **Network → Ingresses & Routes**. Verify `test-routing-ingress` is
   listed, then inspect **Summary**, **Inspect**, and **Patch**. The backend
   must reference `test-routing-service:8080` and the configured class.
3. With a running Ingress controller, obtain its reachable address and request
   the configured host. HTTP must return 200. Patch the Ingress backend to an
   invalid Service name and verify the request no longer succeeds; restore the
   backend and verify HTTP 200 returns.
4. Open **Network → Ingress Classes** and verify the installed class is shown.
   If the class, controller, or page is unavailable, record the prerequisite
   result instead of treating the traffic check as passed.
5. When Gateway API is installed, open **Gateway Classes**, **Gateways**, and
   **HTTPRoutes**. Apply the Gateway API YAML below, then verify each object is
   listed and its **Summary**, **Inspect**, and **Patch** views show the
   parent-to-backend relationship.
6. For an OpenShift cluster, apply a Route that targets
   `test-routing-service:8080`; verify it appears in **Ingresses & Routes**
   and HTTP succeeds. Do not run this optional check on a non-OpenShift
   cluster.
7. Delete the Ingress and any Gateway API/Route resources. Verify they leave
   their lists and backend traffic is no longer exposed. Delete the namespace.

## Optional OpenShift Route setup

Use this only when the cluster serves `route.openshift.io/v1`:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: test-routing-route
  namespace: test-network-routing
spec:
  host: test-routing.example.invalid
  to:
    kind: Service
    name: test-routing-service
  port:
    targetPort: http
```

## Gateway API setup

Use this only after replacing `REPLACE_WITH_INSTALLED_GATEWAY_CLASS` with an
existing GatewayClass name:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: test-routing-gateway
  namespace: test-network-routing
spec:
  gatewayClassName: REPLACE_WITH_INSTALLED_GATEWAY_CLASS
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: test-routing-route
  namespace: test-network-routing
spec:
  parentRefs:
    - name: test-routing-gateway
  rules:
    - backendRefs:
        - name: test-routing-service
          port: 8080
```

## Cleanup

```sh
kubectl delete namespace test-network-routing --ignore-not-found
```
