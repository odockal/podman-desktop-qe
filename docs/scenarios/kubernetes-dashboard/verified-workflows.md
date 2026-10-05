# Additional v0.6.0 workflow checks

These workflows validate the PR #55 scenarios against a connected Kind cluster. Run them through Podman Desktop with `kubectl apply` only for setup or controlled fault injection.

## Resource specification

All verified workflow objects use the `qe-v06-` prefix and the `qe-v06-workflows` namespace. Apply the fixture files in the order below; the names are the canonical names used by the steps and expected results.

| Fixture | Objects created | Important values |
|---------|-----------------|------------------|
| [v06-workloads.yaml](resources/v06-workloads.yaml) | Namespace `qe-v06-workflows`; Deployment `qe-v06-web`; DaemonSet `qe-v06-daemon`; ReplicaSet `qe-v06-replicaset`; Job `qe-v06-job`; CronJob `qe-v06-cron` | `qe-v06-web` starts at 1 replica and uses `nginx:1.25-alpine`; the Job prints `qe-v06-job-complete`; the CronJob prints `qe-v06-cron` |
| [v06-logs.yaml](resources/v06-logs.yaml) | Pod `qe-v06-logs`, container `logger` | Emits `qe-v06-log-line` every second |
| [v06-config.yaml](resources/v06-config.yaml) | ResourceQuota `qe-v06-quota`; LimitRange `qe-v06-limits` | Quota limits Pods, CPU requests, and CPU limits; LimitRange defaults are 100m request and 200m limit |
| [v06-storage.yaml](resources/v06-storage.yaml) | PersistentVolume `qe-v06-pv`; StorageClass `qe-v06-manual` | PV is 1Gi, `ReadWriteOnce`, `Retain`; StorageClass uses `kubernetes.io/no-provisioner` |
| [v06-storage-pvc.yaml](resources/v06-storage-pvc.yaml) | PersistentVolumeClaim `qe-v06-claim` | Requests 500Mi and explicitly binds to `qe-v06-pv` |
| [v06-access-control.yaml](resources/v06-access-control.yaml) | ServiceAccount `qe-v06-reader`; Role and RoleBinding `qe-v06-reader`; ClusterRole and ClusterRoleBinding `qe-v06-node-reader` | Namespaced role allows Pod `get/list`; cluster role allows Node `get/list` |

When creating an additional ad-hoc object through **Apply YAML**, use a deterministic name such as `test-deployment`, keep it in `qe-v06-workflows`, and remove it before cleanup. Do not reuse the canonical fixture names during an Apply YAML test.

## Setup

```sh
kubectl apply -f resources/v06-workloads.yaml
kubectl apply -f resources/v06-logs.yaml
kubectl apply -f resources/v06-config.yaml
kubectl apply -f resources/v06-storage.yaml
kubectl apply -f resources/v06-access-control.yaml
```

Select namespace `qe-v06-workflows` in the Dashboard.

## Workload lifecycle

1. Open Deployments and verify `qe-v06-web` is Running with 1/1 replicas.
2. Scale it to 3 from the Deployment details page and verify three Pods appear.
3. Delete one owned Pod and verify the Deployment recreates it.
4. Scale back to 1 and verify the extra Pods disappear.
5. Check `qe-v06-daemon`, `qe-v06-replicaset`, `qe-v06-job`, and `qe-v06-cron`. Verify ready/current counts, Job completion, and the CronJob schedule.
6. Open details for a workload and confirm Summary, Inspect, and Patch are available.

## Pod logs and annotations

1. Open Pods → `qe-v06-logs` → Logs and verify a new `qe-v06-log-line` appears about every second without reload.
2. Apply the timestamp annotation:

   ```sh
   kubectl -n qe-v06-workflows annotate pod qe-v06-logs kubernetes-dashboard.podman-desktop.io/logs-timestamps=true
   ```

3. Verify ISO timestamps are shown, then remove the annotation and verify plain lines return.

## Storage lifecycle

1. Open Storage Classes and Persistent Volumes. Verify `qe-v06-pv` is Available and `qe-v06-manual` is visible.
2. Apply the claim only after checking the Available state:

   ```sh
   kubectl apply -f resources/v06-storage-pvc.yaml
   ```

3. Open Persistent Volume Claims and verify `qe-v06-claim` becomes Bound to `qe-v06-pv`.
4. Delete the claim from the Dashboard and verify the claim disappears and the retained PV becomes Released.

## Access control

1. Open Config → Service Accounts and Access Control → Roles, RoleBindings, ClusterRoles, and ClusterRoleBindings. The current app places Service Accounts under Config.
2. Inspect Role `qe-v06-reader` and verify the Pod `get/list` rule and the bound ServiceAccount `qe-v06-reader`.
3. Delete RoleBinding `qe-v06-reader` from the Dashboard and verify Role `qe-v06-reader` and ServiceAccount `qe-v06-reader` remain.
4. Inspect ClusterRoleBinding `qe-v06-node-reader` and verify it references ClusterRole `qe-v06-node-reader` and ServiceAccount `qe-v06-reader`.

## Configuration and prerequisites

1. Verify ResourceQuota `qe-v06-quota` and LimitRange `qe-v06-limits` details and hard/default values.
2. HPA scenarios require metrics-server; without it, verify visibility but mark live scaling Partial.
3. Webhook scenarios require a reachable webhook server. Configuration visibility can be tested independently; admission behavior is Partial without a server.
4. Anonymous RBAC requires a restricted kubeconfig and should be tested separately from the workload namespace.

## Cleanup

```sh
kubectl delete -f resources/v06-access-control.yaml
kubectl delete -f resources/v06-storage-pvc.yaml --ignore-not-found
kubectl delete -f resources/v06-storage.yaml
kubectl delete -f resources/v06-config.yaml
kubectl delete -f resources/v06-logs.yaml
kubectl delete -f resources/v06-workloads.yaml
kubectl delete namespace qe-v06-workflows
```

Delete only the temporary resources created by these fixtures.
