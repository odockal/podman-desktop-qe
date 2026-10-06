# Endpoints, EndpointSlices, and NetworkPolicy

## Goal

Verify the dashboard relates Service backends to Endpoints and EndpointSlices,
then presents a NetworkPolicy and its selector accurately. Exercise traffic
denial only on a cluster whose CNI enforces NetworkPolicy.

## Prerequisites

- Connected cluster and permission to create an isolated namespace.
- For the negative connectivity check: a CNI with NetworkPolicy enforcement.
  Without it, perform the display checks and record the behavior check as
  blocked by the environment.

## Setup

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-network-policy
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-backend
  namespace: test-network-policy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-backend
  template:
    metadata:
      labels:
        app: test-backend
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
  name: test-backend
  namespace: test-network-policy
spec:
  selector:
    app: test-backend
  ports:
    - port: 8080
      targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-allow-client
  namespace: test-network-policy
spec:
  podSelector:
    matchLabels:
      app: test-backend
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: test-client
      ports:
        - protocol: TCP
          port: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: test-client
  namespace: test-network-policy
  labels:
    app: test-client
spec:
  containers:
    - name: client
      image: registry.access.redhat.com/ubi9/python-312:latest
      command:
        - python
        - -c
        - |
          import time, urllib.error, urllib.request
          while True:
              try:
                  print(f"status={urllib.request.urlopen('http://test-backend:8080', timeout=3).status}")
              except Exception as error:
                  print(f"error={type(error).__name__}")
              time.sleep(5)
```

## Dashboard workflow

1. Select `test-network-policy`. In **Services**, inspect `test-backend` and
   verify the selector and `8080/TCP` port.
2. In **Endpoints**, verify two backend Pod IPs. In **Endpoint Slices**, verify
   IPv4, port `8080/TCP`, and two ready endpoints match the Service backends.
3. Delete one backend Pod. Refresh **Endpoints** and **Endpoint Slices**;
   confirm Kubernetes replaces it and the ready backend count returns to two.
4. In **Network Policies**, inspect `test-allow-client`: verify policy type
   Ingress, backend selector, client selector, and TCP port 8080 in **Summary**,
   **Inspect**, and **Patch**.
5. When the CNI enforces policies, open `test-client` logs and verify
   `status=200`. Delete `test-allow-client`, then apply this default-deny
   policy and verify the logs change to `error=...`:

   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: test-deny-ingress
     namespace: test-network-policy
   spec:
     podSelector:
       matchLabels:
         app: test-backend
     policyTypes: [Ingress]
   ```

6. Reapply `test-allow-client` and delete `test-deny-ingress`; logs must return
   to `status=200`. Do not mark this behavior passed when the CNI lacks
   enforcement.

## Cleanup

```sh
kubectl delete namespace test-network-policy --ignore-not-found
```
