# ClusterRole scope

## Goal

Verify that a ClusterRoleBinding grants a deliberately narrow cluster-scoped
permission to the same ServiceAccount used in the namespaced workflow.

## Prerequisite

Complete the namespace and ServiceAccount setup in
[Role permission lifecycle](role-permission-lifecycle.md).

## Setup

Apply this YAML:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: test-node-viewer
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: test-node-viewer-binding
subjects:
  - kind: ServiceAccount
    name: test-access-reader
    namespace: test-access-control
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: test-node-viewer
```

## Dashboard workflow

1. Open **Access Control → Cluster Roles**. Verify `test-node-viewer` is
   Running with one rule and exposes **Summary**, **Inspect**, and **Patch**.
2. In **Inspect**, verify the role permits only `get` on `nodes`.
3. Open **Access Control → Cluster Role Bindings**. Verify
   `test-node-viewer-binding` maps `test-access-reader` to `test-node-viewer`.
4. Open its details and verify **Summary**, **Inspect**, and **Patch**.

## Permission and negative checks

```sh
kubectl auth can-i get nodes \
  --as=system:serviceaccount:test-access-control:test-access-reader
```

Expected result: `yes`.

```sh
kubectl auth can-i list nodes \
  --as=system:serviceaccount:test-access-control:test-access-reader
```

Expected result: `no`.

## Cleanup

Delete `test-node-viewer-binding`, then `test-node-viewer`. Finally delete
`test-access-control` if no namespaced workflow still uses it.

## Expected evidence

- Cluster-wide lists distinguish a ClusterRole and ClusterRoleBinding from the
  selected-namespace Role and RoleBinding pages.
- The binding allows only the declared cluster-scoped verb.
