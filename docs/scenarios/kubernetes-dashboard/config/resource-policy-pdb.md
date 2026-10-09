# Resource policy and disruption lifecycle

## Goal

Verify default resource injection, quota usage and rejection, plus visible PDB
state changes caused by a related Deployment.

## What each resource proves

| Resource | Role in the workflow | Observable result |
| --- | --- | --- |
| `test-limits` LimitRange | Supplies default CPU request and limit values when a container omits resources. | The Dashboard Inspect view shows the injected values on `test-defaulted`. |
| `test-quota` ResourceQuota | Caps Pod count and aggregate CPU requests and limits in the namespace. | Its `status.used` changes after an admitted Pod; an oversized Pod is rejected. |
| `test-pdb` PodDisruptionBudget | States that at least one `test-policy-target` Pod should remain available during voluntary eviction. | Its health counters change as Deployment availability changes. |

## Setup

Apply this YAML with `kubectl apply -f -` or Podman Desktop **Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-config-verify
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: test-quota
  namespace: test-config-verify
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    limits.cpu: "4"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: test-limits
  namespace: test-config-verify
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
  name: test-defaulted
  namespace: test-config-verify
spec:
  containers:
    - name: sleeper
      image: registry.access.redhat.com/ubi9/ubi-minimal:latest
      command: ["sh", "-c", "sleep 3600"]
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-policy-target
  namespace: test-config-verify
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-policy-target
  template:
    metadata:
      labels:
        app: test-policy-target
    spec:
      containers:
        - name: web
          image: registry.access.redhat.com/ubi9/ubi-minimal:latest
          resources:
            requests:
              cpu: 100m
            limits:
              cpu: 200m
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: test-pdb
  namespace: test-config-verify
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: test-policy-target
```
The YAML creates `test-quota`, `test-limits`, one defaulted Pod, the two-replica
`test-policy-target` Deployment, and `test-pdb` in
`test-config-verify`.

## LimitRange and ResourceQuota workflow

1. Open **Config → Limit Ranges** and inspect `test-limits`. Verify the
   default request is `100m` CPU and default limit is `200m` CPU.
2. Open **Compute → Pods**, open `test-defaulted`, and use **Inspect** to
   verify those CPU values were injected into its container resources.
3. Open **Config → Resource Quotas**, inspect `test-quota`, and record
   `status.used`.
4. Record `status.used` as the baseline, then apply this usage Pod:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-quota-usage
     namespace: test-config-verify
   spec:
     containers:
       - name: sleeper
         image: registry.access.redhat.com/ubi9/ubi-minimal:latest
         command: ["sh", "-c", "sleep 3600"]
         resources:
           requests:
             cpu: 100m
           limits:
             cpu: 200m
   ```

   Verify `test-quota-usage` is Running. Refresh the quota page and compare
   `status.used` with the baseline: `pods` increases by one, `requests.cpu`
   by `100m`, and `limits.cpu` by `200m`.
5. Apply the over-quota Pod:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-overquota
     namespace: test-config-verify
   spec:
     containers:
       - name: sleeper
         image: registry.access.redhat.com/ubi9/ubi-minimal:latest
         command: ["sh", "-c", "sleep 3600"]
         resources:
           requests:
             cpu: "3"
           limits:
             cpu: "3"
   ```

6. Expect Kubernetes admission to reject the request. `test-overquota` must
   not appear as a Running Pod. Capture the Apply YAML result as product
   evidence.

## PDB workflow

1. Open **Config → Pod Disruption Budgets** and inspect `test-pdb`.
   With the target at two replicas, expect healthy `2`, desired healthy `1`,
   and allowed disruptions `1`.
2. In **Compute → Deployments**, use the dashboard Scale action to change
   `test-policy-target` from `2` to `1` replicas. Refresh the PDB page and
   verify its counters update.
3. Scale back to `2`, wait for both Pods to be Running, and confirm the PDB
   returns to its original healthy and allowed-disruption values.

Scaling the Deployment from two replicas to one deletes a Pod because the
Deployment controller is reducing desired replicas. The Pods do **not** finish
because of completions, and this is not an eviction test. The PDB is not the
actor that terminates the Pod here; the check only proves that its Dashboard
counters reflect the resulting availability. A true PDB enforcement test would
need a voluntary eviction against a node, which is intentionally outside this
safe local workflow.

## Cleanup

If the configuration-dependencies workflow is not using the same namespace:

```sh
kubectl delete namespace test-config-verify --ignore-not-found
```
