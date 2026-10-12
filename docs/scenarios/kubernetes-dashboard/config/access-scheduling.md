# Access control and scheduling configuration

## Goal

Verify namespaced and cluster-scoped RBAC relationships, live authorization,
Lease refresh, PriorityClass, and RuntimeClass presentation.

## What each resource does

| Resource | Kubernetes purpose | What this workflow checks |
| --- | --- | --- |
| ServiceAccount, Role, and RoleBinding | Give a workload identity and namespaced API permissions. | `test-reader` can list Pods but cannot read ConfigMaps. |
| ClusterRole and ClusterRoleBinding | Grant the same identity permissions for cluster-scoped resources. | `test-reader` can read Nodes. |
| Lease | Stores lightweight leader-election or heartbeat state. It does not schedule or restart Pods. | Editing the holder identity and transition count refreshes the list and Inspect views. |
| PriorityClass | Assigns scheduling priority to Pods. It only has an effect when the scheduler must choose between competing Pods. | The Dashboard shows its value and default flag; the RuntimeClass Pod references it. |
| RuntimeClass | Selects a container runtime handler configured on the node. | The Dashboard presents the class and a Pod can use it only when the handler exists. |

## Setup

Apply this YAML with `kubectl apply -f -` or Podman Desktop **Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-access-verify
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-reader
  namespace: test-access-verify
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: test-reader
  namespace: test-access-verify
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: test-reader
  namespace: test-access-verify
subjects:
  - kind: ServiceAccount
    name: test-reader
    namespace: test-access-verify
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: test-reader
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: test-node-reader
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: test-node-reader
subjects:
  - kind: ServiceAccount
    name: test-reader
    namespace: test-access-verify
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: test-node-reader
---
apiVersion: coordination.k8s.io/v1
kind: Lease
metadata:
  name: test-lease
  namespace: test-access-verify
spec:
  holderIdentity: test-initial-holder
  leaseDurationSeconds: 30
  leaseTransitions: 1
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: test-priority
value: 100000
globalDefault: false
description: Test priority workflow
---
apiVersion: v1
kind: Pod
metadata:
  name: test-rbac-check
  namespace: test-access-verify
spec:
  serviceAccountName: test-reader
  restartPolicy: Never
  containers:
    - name: check
      image: registry.access.redhat.com/ubi9/python-312:latest
      command:
        - python
        - -c
        - |
          import os, ssl, time, urllib.error, urllib.request
          api = "https://kubernetes.default.svc"
          token = open("/var/run/secrets/kubernetes.io/serviceaccount/token").read().strip()
          ca = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
          context = ssl.create_default_context(cafile=ca)
          headers = {"Authorization": f"Bearer {token}"}
          def status(path):
              try:
                  return urllib.request.urlopen(urllib.request.Request(api + path, headers=headers), context=context).status
              except urllib.error.HTTPError as error:
                  return error.code
          namespace = os.environ["POD_NAMESPACE"]
          print(f"pods={status(f'/api/v1/namespaces/{namespace}/pods')} configmaps={status(f'/api/v1/namespaces/{namespace}/configmaps')} nodes={status('/api/v1/nodes')}")
          time.sleep(3600)
      env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```
It creates `test-access-verify`, the `test-reader` ServiceAccount,
Role/RoleBinding, `test-node-reader` ClusterRole/ClusterRoleBinding,
`test-lease`, `test-priority`, and the `test-rbac-check` Pod.

## RBAC workflow

1. Open **Config → Service Accounts**, **Access Control → Roles**, and
   **Role Bindings**. Select `test-access-verify` for namespaced pages.
2. Inspect `test-reader` in each page. Verify the Role grants only Pod
   `get` and `list`, and the RoleBinding subject is the same ServiceAccount.
3. Open **Access Control → Cluster Roles** and **Cluster Role Bindings**.
   Verify `test-node-reader` grants Node `get` and `list` and is bound to
   the reader ServiceAccount.
4. Open the logs for `test-rbac-check`. Expect:

   ```text
   pods=200 configmaps=403 nodes=200
   ```

   This proves the listed relationships enforce both an allowed and a denied
   API operation.

## Lease and PriorityClass workflow

1. Open **Config → Leases**, inspect `test-lease`, and verify its initial
   holder is `test-initial-holder`.
2. Use **Apply YAML** to update the Lease. Refresh the list and Inspect view to
   confirm both values update.

   ```yaml
   apiVersion: coordination.k8s.io/v1
   kind: Lease
   metadata:
     name: test-lease
     namespace: test-access-verify
   spec:
     holderIdentity: test-updated-holder
     leaseDurationSeconds: 30
     leaseTransitions: 2
   ```
3. Open **Config → Priority Classes** and inspect `test-priority`. Verify
   the value is `100000` and it is not the global default.

   `test-priority` does not preempt another Pod in this workflow because the
   Kind cluster has available capacity. Its purpose is to verify presentation
   and the Pod reference below. Preemption needs deliberately constrained node
   capacity and is not a stable release test.

## RuntimeClass workflow

Only run this part when the cluster node runtime supports the `runc` handler.
`RuntimeClass` is not a request to install a runtime; it selects a handler
already configured by the node runtime. Check availability first:

```sh
kubectl get runtimeclass
```
Apply this YAML:

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: test-runc
handler: runc
---
apiVersion: v1
kind: Pod
metadata:
  name: test-priority-runtime
  namespace: test-access-verify
spec:
  priorityClassName: test-priority
  runtimeClassName: test-runc
  containers:
    - name: sleeper
      image: registry.access.redhat.com/ubi9/ubi-minimal:latest
      command: ["sh", "-c", "sleep 3600"]
```

Open **Config → Runtime Classes** and inspect `test-runc`. Then inspect
`test-priority-runtime` in **Pods** and verify it is Running with both
`priorityClassName: test-priority` and `runtimeClassName: test-runc`.
If the handler is unavailable, stop this sub-workflow and record the missing
runtime handler as the prerequisite failure.

## Cleanup

```sh
kubectl delete namespace test-access-verify --ignore-not-found
kubectl delete clusterrolebinding test-node-reader --ignore-not-found
kubectl delete clusterrole test-node-reader --ignore-not-found
kubectl delete priorityclass test-priority --ignore-not-found
kubectl delete runtimeclass test-runc --ignore-not-found
```
