# Access control and scheduling configuration

## Goal

Verify namespaced and cluster-scoped RBAC relationships, live authorization,
Lease refresh, PriorityClass, and RuntimeClass presentation.

## Setup

Apply this YAML with `kubectl apply -f -` or Podman Desktop **Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: qe-v06-access-verify
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: qe-v06-reader
  namespace: qe-v06-access-verify
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: qe-v06-reader
  namespace: qe-v06-access-verify
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: qe-v06-reader
  namespace: qe-v06-access-verify
subjects:
  - kind: ServiceAccount
    name: qe-v06-reader
    namespace: qe-v06-access-verify
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: qe-v06-reader
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: qe-v06-node-reader
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: qe-v06-node-reader
subjects:
  - kind: ServiceAccount
    name: qe-v06-reader
    namespace: qe-v06-access-verify
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: qe-v06-node-reader
---
apiVersion: coordination.k8s.io/v1
kind: Lease
metadata:
  name: qe-v06-lease
  namespace: qe-v06-access-verify
spec:
  holderIdentity: qe-v06-initial-holder
  leaseDurationSeconds: 30
  leaseTransitions: 1
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: qe-v06-priority
value: 100000
globalDefault: false
description: QE priority workflow
---
apiVersion: v1
kind: Pod
metadata:
  name: qe-v06-rbac-check
  namespace: qe-v06-access-verify
spec:
  serviceAccountName: qe-v06-reader
  restartPolicy: Never
  containers:
    - name: check
      image: curlimages/curl:8.8.0
      command:
        - sh
        - -ec
        - |
          api=https://kubernetes.default.svc
          token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
          ca=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          headers="Authorization: Bearer $token"
          pods=$(curl -s -o /dev/null -w '%{http_code}' --cacert "$ca" -H "$headers" "$api/api/v1/namespaces/$POD_NAMESPACE/pods")
          configmaps=$(curl -s -o /dev/null -w '%{http_code}' --cacert "$ca" -H "$headers" "$api/api/v1/namespaces/$POD_NAMESPACE/configmaps")
          nodes=$(curl -s -o /dev/null -w '%{http_code}' --cacert "$ca" -H "$headers" "$api/api/v1/nodes")
          echo "pods=$pods configmaps=$configmaps nodes=$nodes"
          sleep 3600
      env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```
It creates `qe-v06-access-verify`, the `qe-v06-reader` ServiceAccount,
Role/RoleBinding, `qe-v06-node-reader` ClusterRole/ClusterRoleBinding,
`qe-v06-lease`, `qe-v06-priority`, and the `qe-v06-rbac-check` Pod.

## RBAC workflow

1. Open **Config → Service Accounts**, **Access Control → Roles**, and
   **Role Bindings**. Select `qe-v06-access-verify` for namespaced pages.
2. Inspect `qe-v06-reader` in each page. Verify the Role grants only Pod
   `get` and `list`, and the RoleBinding subject is the same ServiceAccount.
3. Open **Access Control → Cluster Roles** and **Cluster Role Bindings**.
   Verify `qe-v06-node-reader` grants Node `get` and `list` and is bound to
   the reader ServiceAccount.
4. Open the logs for `qe-v06-rbac-check`. Expect:

   ```text
   pods=200 configmaps=403 nodes=200
   ```

   This proves the listed relationships enforce both an allowed and a denied
   API operation.

## Lease and PriorityClass workflow

1. Open **Config → Leases**, inspect `qe-v06-lease`, and verify its initial
   holder is `qe-v06-initial-holder`.
2. Use **Apply YAML** to update the Lease. Refresh the list and Inspect view to
   confirm both values update.

   ```yaml
   apiVersion: coordination.k8s.io/v1
   kind: Lease
   metadata:
     name: qe-v06-lease
     namespace: qe-v06-access-verify
   spec:
     holderIdentity: qe-v06-updated-holder
     leaseDurationSeconds: 30
     leaseTransitions: 2
   ```
3. Open **Config → Priority Classes** and inspect `qe-v06-priority`. Verify
   the value is `100000` and it is not the global default.

## RuntimeClass workflow

Only run this part when the cluster node runtime supports the `runc` handler.
Apply this YAML:

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: qe-v06-runc
handler: runc
---
apiVersion: v1
kind: Pod
metadata:
  name: qe-v06-priority-runtime
  namespace: qe-v06-access-verify
spec:
  priorityClassName: qe-v06-priority
  runtimeClassName: qe-v06-runc
  containers:
    - name: sleeper
      image: busybox:1.36
      command: ["sh", "-c", "sleep 3600"]
```

Open **Config → Runtime Classes** and inspect `qe-v06-runc`. Then inspect
`qe-v06-priority-runtime` in **Pods** and verify it is Running with both
`priorityClassName: qe-v06-priority` and `runtimeClassName: qe-v06-runc`.
If the handler is unavailable, stop this sub-workflow and record the missing
runtime handler as the prerequisite failure.

## Cleanup

```sh
kubectl delete namespace qe-v06-access-verify --ignore-not-found
kubectl delete clusterrolebinding qe-v06-node-reader --ignore-not-found
kubectl delete clusterrole qe-v06-node-reader --ignore-not-found
kubectl delete priorityclass qe-v06-priority --ignore-not-found
kubectl delete runtimeclass qe-v06-runc --ignore-not-found
```
