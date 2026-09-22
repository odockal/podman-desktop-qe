# WF-13: Anonymous User / RBAC Restrictions

This scenario verifies that the Dashboard correctly handles an anonymous (no-permission) kubeconfig: all resource pages show "Not accessible" and no data is leaked.

## Prerequisites

- Podman Desktop with the Kubernetes Dashboard extension installed and active.
- An anonymous kubeconfig is available at `tests/resources/empty-kube-config` in the k8s-dashboard repository.

## Scenario Steps

1. **Load the anonymous kubeconfig**  
   Go to Preferences → Kubernetes → Kubeconfig and select the anonymous kubeconfig (`empty-kube-config`).  
   **Expected:** The Dashboard transitions to the anonymous context.

2. **Check dashboard overview tiles**  
   Observe the dashboard overview tile counts.  
   **Expected:** All tile counts show `-` (dash) — not numeric values. The Dashboard cannot read cluster state.

3. **Navigate to Deployments**  
   Open the Deployments page.  
   **Expected:** A "Not accessible" message is shown instead of a resource list.

4. **Navigate to Pods, Services, and Secrets**  
   Open the Pods page, then Services, then Secrets.  
   **Expected:** Each page shows the same "Not accessible" message. No resource data is visible or leaked.

5. **Restore the valid kubeconfig**  
   Go back to Preferences → Kubernetes → Kubeconfig and select the valid cluster kubeconfig.  
   **Expected:** The Dashboard reconnects. Tile counts return to correct numeric values. Resource pages show their resource lists again.
