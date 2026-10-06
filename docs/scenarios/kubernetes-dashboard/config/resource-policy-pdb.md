# Resource policy and disruption lifecycle

## Goal

Verify default resource injection, quota usage and rejection, plus visible PDB
state changes caused by a related Deployment.

## Setup

Apply this YAML with `kubectl apply -f -` or Podman Desktop **Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: qe-v06-config-verify
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: qe-v06-quota
  namespace: qe-v06-config-verify
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    limits.cpu: "4"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: qe-v06-limits
  namespace: qe-v06-config-verify
spec:
  limits:
    - type: Container
      default:
        cpu: 200m
      defaultRequest:
        cpu: 100m
---
apiVersion: v1
kind: Pod
metadata:
  name: qe-v06-defaulted
  namespace: qe-v06-config-verify
spec:
  containers:
    - name: sleeper
      image: busybox:1.36
      command: ["sh", "-c", "sleep 3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: qe-v06-quota-usage
  namespace: qe-v06-config-verify
spec:
  containers:
    - name: sleeper
      image: busybox:1.36
      command: ["sh", "-c", "sleep 3600"]
      resources:
        requests:
          cpu: 100m
        limits:
          cpu: 200m
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qe-v06-policy-target
  namespace: qe-v06-config-verify
spec:
  replicas: 2
  selector:
    matchLabels:
      app: qe-v06-policy-target
  template:
    metadata:
      labels:
        app: qe-v06-policy-target
    spec:
      containers:
        - name: web
          image: nginx:1.25-alpine
          resources:
            requests:
              cpu: 100m
            limits:
              cpu: 200m
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: qe-v06-pdb
  namespace: qe-v06-config-verify
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: qe-v06-policy-target
```
The YAML creates `qe-v06-quota`, `qe-v06-limits`, two Pods, the two-replica
`qe-v06-policy-target` Deployment, and `qe-v06-pdb` in
`qe-v06-config-verify`.

## LimitRange and ResourceQuota workflow

1. Open **Config → Limit Ranges** and inspect `qe-v06-limits`. Verify the
   default request is `100m` CPU and default limit is `200m` CPU.
2. Open **Compute → Pods**, open `qe-v06-defaulted`, and use **Inspect** to
   verify those CPU values were injected into its container resources.
3. Open **Config → Resource Quotas**, inspect `qe-v06-quota`, and record
   `status.used`.
4. Verify `qe-v06-quota-usage` is Running. Refresh the quota page and confirm
   the pod and CPU usage increased.
5. Apply the over-quota Pod:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: qe-v06-overquota
     namespace: qe-v06-config-verify
   spec:
     containers:
       - name: sleeper
         image: busybox:1.36
         command: ["sh", "-c", "sleep 3600"]
         resources:
           requests:
             cpu: "3"
           limits:
             cpu: "3"
   ```

6. Expect Kubernetes admission to reject the request. `qe-v06-overquota` must
   not appear as a Running Pod. Capture the Apply YAML result as product
   evidence.

## PDB workflow

1. Open **Config → Pod Disruption Budgets** and inspect `qe-v06-pdb`.
   With the target at two replicas, expect healthy `2`, desired healthy `1`,
   and allowed disruptions `1`.
2. In **Compute → Deployments**, use the dashboard Scale action to change
   `qe-v06-policy-target` from `2` to `1` replicas. Refresh the PDB page and
   verify its counters update.
3. Scale back to `2`, wait for both Pods to be Running, and confirm the PDB
   returns to its original healthy and allowed-disruption values.

## Cleanup

If the configuration-dependencies workflow is not using the same namespace:

```sh
kubectl delete namespace qe-v06-config-verify --ignore-not-found
```
