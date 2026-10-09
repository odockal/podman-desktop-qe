# Ingress and Gateway API lifecycle

## Goal

Verify that the Network section exposes the routing resources installed in the
cluster, relates an Ingress to a Service backend, and shows Gateway API
resources only when their APIs and controller are available.

## Resources in this workflow

| Resource | What it does in this test |
| --- | --- |
| Namespace | Isolates the routing fixture in `test-network-routing`. |
| Deployment | Keeps two `test-routing-web` HTTP Pods running. |
| Service | Gives the routing resources one stable backend: `test-routing-service:8080`. |
| IngressClass | Selects the installed Ingress controller that will implement an Ingress. |
| Ingress | Maps the test host and path to the Service backend. It is the standard Kubernetes HTTP-routing API. |
| GatewayClass | Identifies the controller implementation used to program a Gateway. |
| Gateway | Creates a controller-managed entry point and HTTP listener. |
| HTTPRoute | Attaches routing rules to the Gateway and sends matching requests to the Service. |
| OpenShift Route | OpenShift-specific alternative to Ingress; it exposes the same Service through a Route host. |

## Cluster preparation: kind with Contour

The Ingress object only describes a route; an Ingress controller must turn that
description into reachable traffic. This workflow uses [Contour](https://projectcontour.io/)
and its Envoy data plane. On kind, the Envoy Service is normally a
`LoadBalancer` without an external address, so a temporary port-forward makes
the controller reachable from the host for the HTTP check.

First check whether Contour is already installed:

```sh
kubectl get pods -n projectcontour
```

If the namespace or controller Pods are absent, install Contour and wait for
both its control plane and Envoy data plane:

```sh
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl wait --for=condition=Available deployment/contour -n projectcontour --timeout=120s
kubectl rollout status daemonset/envoy -n projectcontour --timeout=120s
```

Register the `contour` IngressClass. This maps an Ingress that specifies
`ingressClassName: contour` to Contour's controller; without it, the Ingress
can be stored by Kubernetes but will not be programmed for traffic.

```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: contour
spec:
  controller: projectcontour.io/ingress-controller
```

Save the YAML as `contour-ingressclass.yaml`, then apply and verify it:

```sh
kubectl apply -f contour-ingressclass.yaml
kubectl get ingressclass contour
```

For the traffic step, keep this command running in one terminal:

```sh
kubectl port-forward -n projectcontour service/envoy 18080:80
```

The test request uses `--resolve` so the test hostname reaches that local
Envoy endpoint without editing the host's DNS or `/etc/hosts`:

```sh
curl --fail --silent --show-error \
  --resolve test-routing.example.invalid:18080:127.0.0.1 \
  http://test-routing.example.invalid:18080/
```

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
```

The cluster-preparation steps above create the `contour` class. When using a
different controller, replace it with that controller's advertised class. If
no class is installed, apply only the Namespace, Deployment, and Service and
keep the Ingress portion as blocked by the prerequisite.

## Dashboard workflow

### 1. Ingress lifecycle

1. Open **Network → Ingress Classes** and verify `contour` lists controller
   `projectcontour.io/ingress-controller`. If the list is empty, complete
   **Cluster preparation: kind with Contour** before applying the Ingress.
2. Apply the base fixture with `ingressClassName: contour`.
   In **Network → Services**, verify `test-routing-service` exposes
   `8080/TCP`.
3. Open **Network → Ingresses & Routes**. Verify `test-routing-ingress` is
   listed. **Inspect** and **Patch** must show the selected class and backend
   `test-routing-service:8080`. The **Summary** tab is useful for status and
   metadata; use Inspect/Patch for the complete routing rule.

### 2. Ingress traffic and recovery

1. Run the documented Envoy port-forward and request
   `test-routing.example.invalid`; expect HTTP 200.
2. In the Ingress **Patch** tab, edit the complete manifest so the backend
   Service name is invalid, then select **Patch resource**. The request must
   no longer return HTTP 200. With Contour, a missing backend can appear as an
   empty response (`curl` status `000`); record the observed failure rather
   than expecting one specific HTTP error code.
3. Restore `test-routing-service:8080` in the complete manifest and select
   **Patch resource**. HTTP 200 must return.

### 3. Gateway API relationships

1. Run this check only when the Gateway API CRDs and a controller exist. In
   **Gateway Classes**, select an installed class; otherwise record the whole
   Gateway check as blocked.
2. Apply the Gateway and HTTPRoute YAML below with that class. In **Gateways**,
   verify `test-routing-gateway` and its HTTP listener. In **HTTPRoutes**,
   verify `test-routing-route` references that Gateway and sends traffic to
   `test-routing-service:8080`.
3. Use **Inspect** or **Patch** for the complete parent-to-backend references.
   On OpenShift, an optional Route targeting the same Service may be verified
   in **Ingresses & Routes**; it does not need a separate test case.

After the active routing checks, delete the Ingress and any Gateway API or
Route resources, verify they leave their lists, then delete the namespace.

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
