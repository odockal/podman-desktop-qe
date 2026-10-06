# Service and port-forwarding lifecycle

## Goal

Verify a selector-backed Service exposes its Deployment Pods as endpoints,
forwards real HTTP traffic locally, reports a broken selector, and recovers
when the selector is restored.

## Prerequisites

- Connected cluster and permission to create an isolated namespace.
- Local port `50000` is free for the Service forward.

## Setup

Apply this YAML with **Network → Apply YAML** or `kubectl apply -f -`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-network-connectivity
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-network-web
  namespace: test-network-connectivity
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-network-web
  template:
    metadata:
      labels:
        app: test-network-web
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
  name: test-network-service
  namespace: test-network-connectivity
spec:
  selector:
    app: test-network-web
  ports:
    - name: http
      port: 8080
      targetPort: 8080
```

## Dashboard workflow

1. Select `test-network-connectivity`. In **Network → Services**, inspect
   `test-network-service`: it must be ClusterIP on `8080/TCP`, select
   `app=test-network-web`, and offer **Summary**, **Inspect**, and **Patch**.
2. In **Endpoints** or the Service detail view, verify two ready backends match
   the Deployment's two Running Pods.
3. Start a Service forward from `8080` to local `50000`. On **Port
   Forwarding**, verify Name=`test-network-service`, Type=Service, Local=`50000`,
   and Remote=`8080`. `curl -fsS http://localhost:50000` must return HTTP 200.
4. Patch the Service selector to `app: test-network-broken`. Refresh Endpoints:
   it must be empty. The existing forward must no longer return HTTP 200.
5. Patch the selector back to `app: test-network-web`. Verify the endpoints and
   HTTP 200 response return.
6. Delete the forward in **Port Forwarding**, then verify `curl` to port 50000
   is refused. Delete the namespace and confirm the Service and Pods disappear.

## Cleanup

```sh
kubectl delete namespace test-network-connectivity --ignore-not-found
```
