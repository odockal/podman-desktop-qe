# Additional v0.6.0 workflow checks

These workflows validate the PR #55 scenarios against a connected Kind cluster. Run them through Podman Desktop with `kubectl apply` only for setup or controlled fault injection.

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
5. Check DaemonSets, ReplicaSets, Jobs, and CronJobs. Verify ready/current counts, Job completion, and the CronJob schedule.
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
2. Inspect `qe-v06-reader` and verify the Pod get/list rule and the bound ServiceAccount.
3. Delete the RoleBinding from the Dashboard and verify the Role and ServiceAccount remain.
4. Inspect the cluster-scoped binding and repeat the independence check for the ClusterRole.

## Configuration and prerequisites

1. Verify ResourceQuota and LimitRange details and hard/default values.
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
