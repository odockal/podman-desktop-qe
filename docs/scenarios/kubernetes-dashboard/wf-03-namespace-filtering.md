# WF-03: Namespace Filtering

This scenario verifies that the namespace selector correctly filters resources across all workload pages.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the namespace-filtering resources:
  ```bash
  kubectl apply -f resources/v06-namespace-filtering.yaml
  ```
  Resource file: [v06-namespace-filtering.yaml](resources/v06-namespace-filtering.yaml)

The file creates resources in both `default` and `ns2` namespaces:
- `default`: `qe-v06-default-web`, `qe-v06-default-pod`, `qe-v06-default-daemon`, `qe-v06-default-replicaset`
- `qe-v06-ns2`: `qe-v06-ns2-web`, `qe-v06-ns2-pod`, `qe-v06-ns2-daemon`, `qe-v06-ns2-replicaset`

## Scenario Steps

1. **Verify default namespace shows only its resources**
   Confirm the namespace selector is set to `default`. Navigate to the Deployments page.
   **Expected:** `qe-v06-default-web` is visible. `qe-v06-ns2-web` is absent.

2. **Switch to qe-v06-ns2 and verify its resources appear**
   Change the namespace selector to `qe-v06-ns2`.
   **Expected:** `qe-v06-ns2-web` appears; `qe-v06-default-web` disappears. The Pods page shows `qe-v06-ns2-pod`, DaemonSets shows `qe-v06-ns2-daemon`, and ReplicaSets shows `qe-v06-ns2-replicaset`.

3. **Switch back to default and verify isolation**
   Change the namespace selector back to `default`.
   **Expected:** `qe-v06-default-web` returns. `qe-v06-ns2` resources are no longer visible on any page.

## Cleanup

```bash
kubectl delete -f resources/v06-namespace-filtering.yaml --ignore-not-found
```
