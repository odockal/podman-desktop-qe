# Network connectivity workflow

## Goal

Verify the connected network path in one workflow: a Deployment backs a
Service, Kubernetes generates its Endpoints and EndpointSlice, the dashboard
forwards HTTP traffic locally, selector failure recovers, and NetworkPolicy
allows then denies the client traffic. Testers do not create Endpoints or
EndpointSlices: Kubernetes creates and updates them from the Service selector
and ready Pods.

## Prerequisites

- Connected cluster and permission to create an isolated namespace.
- Permission to list and get Services, Endpoints, EndpointSlices,
  NetworkPolicies, Deployments, and Pods in that namespace. If **Network →
  Services** says **Not
  accessible**, correct the connected-context RBAC before starting this test.
- Local port `50000` is free for the Service forward.
- A CNI that enforces NetworkPolicy is required only for the allow/deny traffic
  check. Run the display and Service checks on any cluster; mark the policy
  behavior check blocked when that CNI capability is unavailable.

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
---
apiVersion: v1
kind: Pod
metadata:
  name: test-network-client
  namespace: test-network-connectivity
  labels:
    app: test-network-client
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
                  print(f"status={urllib.request.urlopen('http://test-network-service:8080', timeout=3).status}")
              except Exception as error:
                  print(f"error={type(error).__name__}")
              time.sleep(5)
```

## Dashboard workflow

1. Select `test-network-connectivity`. In **Network → Services**, inspect
   `test-network-service`: it must be ClusterIP on `8080/TCP`, select
   `app=test-network-web`, and offer **Summary**, **Inspect**, and **Patch**.
2. In **Endpoints**, verify two ready backend Pod IPs and port `8080/TCP`.
   In **Endpoint Slices**, verify one IPv4 slice whose port is `8080/TCP` and
   whose two ready endpoints match those same Pods. These are generated
   observations of `test-network-service`, not independently applied fixtures.
3. Delete one `test-network-web` Pod from the Pods page. The Deployment must
   replace it. Refresh **Endpoints** and **Endpoint Slices** and confirm the
   ready backend count returns to two and includes the replacement Pod.
4. Open the Service **Summary** tab and start a forward from `8080` to local
   `50000`. On **Network → Port Forwarding**, verify
   Name=`test-network-service`, Type=Service, Local=`50000`, and Remote=`8080`.
   `curl -fsS http://localhost:50000` must return HTTP 200.
5. In the Service **Patch** tab, edit the current complete manifest so the
   selector is `app: test-network-broken`, then select **Patch resource**.
   Do not replace the editor with a partial `spec` fragment. Refresh
   **Endpoints** and **Endpoint Slices**: both must have no ready backends. The
   existing forward must no longer return HTTP 200; if the UI reports an error,
   it must clearly explain that no backend Pod is available rather than expose
   an undefined Pod value.
6. In the same complete manifest, restore the selector to
   `app: test-network-web` and select **Patch resource**. Verify the Endpoints,
   EndpointSlice, client logs, and HTTP 200 response return.
7. Apply this policy from **Network → Apply YAML** or `kubectl apply -f -`.
   In **Network → Network Policies**, verify policy type `Ingress` and backend
   selector `app=test-network-web` in the list. Open the policy and use
   **Inspect** or **Patch** to verify the client selector and TCP port `8080`.
   The policy **Summary** tab currently shows metadata only.

   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: test-network-allow-client
     namespace: test-network-connectivity
   spec:
     podSelector:
       matchLabels:
         app: test-network-web
     policyTypes: [Ingress]
     ingress:
       - from:
           - podSelector:
               matchLabels:
                 app: test-network-client
         ports:
           - protocol: TCP
             port: 8080
   ```

8. When the CNI enforces NetworkPolicy, open `test-network-client` logs and
   verify `status=200`. Delete `test-network-allow-client`, then apply the
   default-deny policy below. Logs must change to `error=...`. Reapply the
   allow policy and delete the default-deny policy; logs must return to
   `status=200`.

   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: test-network-deny-ingress
     namespace: test-network-connectivity
   spec:
     podSelector:
       matchLabels:
         app: test-network-web
     policyTypes: [Ingress]
   ```

9. Delete the forward in **Port Forwarding**, then verify `curl` to port 50000
   is refused. Delete the namespace and confirm the Service, Pods, generated
   Endpoints, EndpointSlice, NetworkPolicies, and forwarding entry disappear.

## Cleanup

```sh
kubectl delete namespace test-network-connectivity --ignore-not-found
```
