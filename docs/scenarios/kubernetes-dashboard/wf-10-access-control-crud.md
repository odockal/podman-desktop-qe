# WF-10: Access Control CRUD (New in 0.6.0)

This scenario verifies that RBAC resources (ServiceAccounts, Roles, RoleBindings, ClusterRoles, ClusterRoleBindings) and ResourceQuotas are visible in the Dashboard's dedicated Access Control section, and that deletions are isolated (deleting a binding does not delete the role).

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the access control resources:
  ```bash
  kubectl apply -f access-control.yaml
  ```
  Resource file: [access-control.yaml](resources/access-control.yaml)

## Scenario Steps

### Sidebar

1. **Verify Access Control section in navigation**  
   Check the left navigation sidebar in the Dashboard.  
   **Expected:** An "Access Control" section is visible, separate from Compute, Config, Network, and Storage.

### Verify Resources

2. **Check Service Accounts**  
   Navigate to Service Accounts (namespace: default).  
   **Expected:** `test-sa` appears.

3. **Check Role details**  
   Navigate to Roles and verify `test-role` appears with Rules count=1. Open the details page.  
   **Expected:** The rule shows `resources=["pods"], verbs=["get","list"]`.

4. **Check Role Binding**  
   Navigate to Role Bindings and verify `test-rolebinding` shows Role=`test-role` and subject `ServiceAccount/test-sa`.

### Delete Binding, Verify Role Survives

5. **Delete test-rolebinding via Dashboard**  
   Use the delete action on `test-rolebinding`.  
   **Expected:** `test-rolebinding` disappears from Role Bindings.

6. **Verify test-role still exists**  
   Navigate to Roles.  
   **Expected:** `test-role` is still present — deleting the binding does not delete the role.

7. **Verify test-sa still exists**  
   Navigate to Service Accounts.  
   **Expected:** `test-sa` is still present.

### Cluster-Scoped Resources

8. **Check ClusterRole details**  
   Navigate to Cluster Roles and verify `test-clusterrole` appears alongside system roles (e.g., cluster-admin). Open the details page.  
   **Expected:** The rule shows `resources=["nodes"], verbs=["get","list"]`.

9. **Check ClusterRoleBinding**  
   Navigate to Cluster Role Bindings and verify `test-clusterrolebinding` shows Role=`test-clusterrole` and subject `ServiceAccount/test-sa`.

10. **Delete test-clusterrolebinding via Dashboard**  
    Use the delete action on `test-clusterrolebinding`.  
    **Expected:** `test-clusterrolebinding` disappears from Cluster Role Bindings. `test-clusterrole` is still present in Cluster Roles.

## Cleanup

```bash
kubectl delete -f access-control.yaml
```
