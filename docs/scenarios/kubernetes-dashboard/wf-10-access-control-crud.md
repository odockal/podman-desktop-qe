# WF-10: Access Control CRUD (New in 0.6.0)

This scenario verifies that RBAC resources (ServiceAccounts, Roles, RoleBindings, ClusterRoles, ClusterRoleBindings) and ResourceQuotas are visible in the Dashboard, and that deletions are isolated (deleting a binding does not delete the role).

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the access control resources:
  ```bash
  kubectl apply -f resources/v06-access-control.yaml
  ```
  Resource file: [v06-access-control.yaml](resources/v06-access-control.yaml)

## Scenario Steps

### Sidebar

1. **Verify Access Control section in navigation**
   Check the left navigation sidebar in the Dashboard.
   **Expected:** An "Access Control" section is visible, separate from Compute, Config, Network, and Storage. Service Accounts are listed under Config.

### Verify Resources

2. **Check Service Accounts**
   Select namespace `qe-v06-workflows`, then navigate to Service Accounts.
   **Expected:** `qe-v06-reader` appears.

3. **Check Role details**
   Navigate to Roles and verify `qe-v06-reader` appears with Rules count=1. Open the details page.
   **Expected:** The rule shows `resources=["pods"], verbs=["get","list"]`.

4. **Check Role Binding**
   Navigate to Role Bindings and verify `qe-v06-reader` shows Role=`qe-v06-reader` and subject `ServiceAccount/qe-v06-reader`.

### Delete Binding, Verify Role Survives

5. **Delete qe-v06-reader RoleBinding via Dashboard**
   Use the delete action on `qe-v06-reader`.
   **Expected:** The RoleBinding disappears from Role Bindings.

6. **Verify qe-v06-reader Role still exists**
   Navigate to Roles.
   **Expected:** `qe-v06-reader` is still present — deleting the binding does not delete the role.

7. **Verify qe-v06-reader still exists**
   Navigate to Service Accounts.
   **Expected:** `qe-v06-reader` is still present.

### Cluster-Scoped Resources

8. **Check ClusterRole details**
   Navigate to Cluster Roles and verify `qe-v06-node-reader` appears alongside system roles (e.g., cluster-admin). Open the details page.
   **Expected:** The rule shows `resources=["nodes"], verbs=["get","list"]`.

9. **Check ClusterRoleBinding**
   Navigate to Cluster Role Bindings and verify `qe-v06-node-reader` shows Role=`qe-v06-node-reader` and subject `ServiceAccount/qe-v06-reader`.

10. **Delete qe-v06-node-reader ClusterRoleBinding via Dashboard**
    Use the delete action on `qe-v06-node-reader`.
    **Expected:** `qe-v06-node-reader` disappears from Cluster Role Bindings. The ClusterRole remains present.

## Cleanup

```bash
kubectl delete -f resources/v06-access-control.yaml --ignore-not-found
```
