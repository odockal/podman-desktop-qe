# Restricted-user Dashboard access

## Goal

Verify that Podman Desktop remains connected when its kubeconfig authenticates
as a valid ServiceAccount with no RBAC bindings, and that the Dashboard shows
its intentional **Not accessible** state without leaking resource data.

## Setup

Apply the following fixture with **Apply YAML** or `kubectl apply -f -`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-restricted-access
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-restricted-user
  namespace: test-restricted-access
---
apiVersion: v1
kind: Secret
metadata:
  name: test-restricted-user-token
  namespace: test-restricted-access
  annotations:
    kubernetes.io/service-account.name: test-restricted-user
type: kubernetes.io/service-account-token
```

Do not create a RoleBinding or ClusterRoleBinding for this ServiceAccount. Wait
until the token Secret is populated, then create a temporary kubeconfig that
uses the active cluster's server URL, certificate authority data, and the token
from `test-restricted-user-token`. Confirm the identity is restricted before
changing Podman Desktop:

```sh
kubectl auth can-i list pods \
  --as=system:serviceaccount:test-restricted-access:test-restricted-user \
  -n test-restricted-access
```

Expected result: `no`.

In **Settings → Preferences → Kubernetes**, temporarily set **Kubeconfig path**
to the restricted kubeconfig. Wait for the Dashboard to show **Connected**.

## Dashboard workflow

1. Open **Dashboard**. The connection must remain active, while summary cards
   show `-` instead of resource counts.
2. Open representative pages: **Namespaces**, **Compute → Pods**,
   **Network → Services**, and **Config → ConfigMaps & Secrets**.
3. Each page must show **Not accessible** and no resource rows. This is an
   authorization result, not a disconnected-cluster state.
4. Restore the original kubeconfig path in **Settings → Preferences →
   Kubernetes**. Confirm the original context reconnects and Dashboard counts
   and resource lists return.

## Cleanup

Delete the test namespace from the original privileged context:

```sh
kubectl delete namespace test-restricted-access --ignore-not-found
```

Delete the temporary restricted kubeconfig and token after restoring the
original configuration.

## Expected evidence

- The Dashboard differentiates an authorized connection with no permissions
  from a missing or disconnected context.
- Restricted pages expose the consistent **Not accessible** state and no data.
- Restoring the original kubeconfig returns the same cluster context and data.
