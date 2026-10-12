# Access Control workflows

These runbooks cover the Kubernetes Dashboard **Access Control** section:
Roles, Role Bindings, Cluster Roles, and Cluster Role Bindings.

| Workflow | Runbook | Resources | Functional outcome |
| --- | --- | --- | --- |
| Namespaced RBAC | [Role permission lifecycle](role-permission-lifecycle.md) | ServiceAccount → Role → RoleBinding | A service account can read ConfigMaps only after its binding exists; deletes stay forbidden. |
| Cluster-scoped RBAC | [ClusterRole scope](cluster-role-scope.md) | ServiceAccount → ClusterRole → ClusterRoleBinding | A service account can get one Node but cannot list Nodes. |
| Restricted Dashboard user | [Restricted-user Dashboard access](restricted-user-rbac.md) | ServiceAccount → token-backed kubeconfig → no RBAC bindings | Dashboard remains connected but exposes no resource data. |

## Common prerequisites

- A connected Kubernetes context where the tester can create RBAC resources.
- Use a disposable Kind or development cluster. The workflows create only
  `test-*` resources.
- Run authorization probes with the active context, for example:

  ```sh
  kubectl auth can-i get configmaps \
    --as=system:serviceaccount:test-access-control:test-access-reader \
    -n test-access-control
  ```

The dashboard has no ServiceAccount page, so the ServiceAccount is created as
part of the fixture and observed through its RoleBinding or ClusterRoleBinding.
