# Role permission lifecycle

## Goal

Verify that a namespaced RoleBinding makes a Role's permissions effective for a
ServiceAccount, while actions outside the Role remain forbidden.

## Setup: identity and Role

Apply this YAML with **Apply YAML** or `kubectl apply -f -`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-access-control
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-access-reader
  namespace: test-access-control
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: test-configmap-reader
  namespace: test-access-control
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list"]
```

Before adding a binding, verify that the identity has no read access:

```sh
kubectl auth can-i get configmaps \
  --as=system:serviceaccount:test-access-control:test-access-reader \
  -n test-access-control
```

Expected result: `no`.

## Dashboard workflow

1. Open **Access Control → Roles**, select `test-access-control`, and verify
   `test-configmap-reader` is Running with one rule.
2. Open the Role details. Verify **Summary**, **Inspect**, and **Patch** are
   available. In **Inspect**, confirm the resource is `configmaps` and the
   verbs are `get` and `list`.
3. Apply the binding:

   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     name: test-configmap-reader-binding
     namespace: test-access-control
   subjects:
     - kind: ServiceAccount
       name: test-access-reader
       namespace: test-access-control
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: Role
     name: test-configmap-reader
   ```

4. Open **Access Control → Role Bindings**, select `test-access-control`, and
   verify the row maps `test-access-reader` to `test-configmap-reader`.
5. Open the binding details. Verify **Summary**, **Inspect**, and **Patch**.

## Permission and negative checks

Verify the allowed action:

```sh
kubectl auth can-i get configmaps \
  --as=system:serviceaccount:test-access-control:test-access-reader \
  -n test-access-control
```

Expected result: `yes`.

Verify an action not granted by the Role:

```sh
kubectl auth can-i delete configmaps \
  --as=system:serviceaccount:test-access-control:test-access-reader \
  -n test-access-control
```

Expected result: `no`.

## Recovery and cleanup

1. Delete `test-configmap-reader-binding` from **Role Bindings**.
2. Repeat the `get configmaps` probe. Expected result: `no`.
3. Reapply the RoleBinding YAML. The same probe must return `yes` again.
4. Delete namespace `test-access-control`; it removes the ServiceAccount,
   Role, and RoleBinding created by this workflow.

## Expected evidence

- The Role and RoleBinding lists show the test resources in the selected
  namespace.
- Inspect exposes the complete RBAC manifest; Summary confirms its metadata.
- The binding changes an authorization decision from denied to allowed.
- A verb absent from the Role remains denied.
