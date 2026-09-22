# WF-03: Namespace Filtering

This scenario verifies that the namespace selector correctly filters resources across all workload pages.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the cluster resources:
  ```bash
  kubectl apply -f cluster-resources.yaml
  ```
  Resource file: [cluster-resources.yaml](resources/cluster-resources.yaml)

The file creates resources in both `default` and `ns2` namespaces:
- `default`: deploy1, deploy2, pod1, pod2, daemonset1, replicaset1
- `ns2`: deploy3, pod3, daemonset2, replicaset2

## Scenario Steps

1. **Verify default namespace shows only its resources**  
   Confirm the namespace selector is set to `default`. Navigate to the Deployments page.  
   **Expected:** `deploy1` and `deploy2` are visible. `deploy3` (which is in `ns2`) is absent.

2. **Switch to ns2 and verify ns2 resources appear**  
   Change the namespace selector to `ns2`.  
   **Expected:** `deploy3` appears; `deploy1` and `deploy2` disappear. The Pods page shows `pod3`. DaemonSets shows `daemonset2`. ReplicaSets shows `replicaset2`.

3. **Switch back to default and verify isolation**  
   Change the namespace selector back to `default`.  
   **Expected:** `deploy1` and `deploy2` return. `ns2` resources are no longer visible on any page.
