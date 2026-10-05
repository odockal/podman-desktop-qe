# Additional v0.6.0 workflow checks

These workflows validate the PR #55 scenarios against a connected Kind cluster. Run them through Podman Desktop with `kubectl apply` only for setup or controlled fault injection.

## Resource specification

All verified workflow objects use the `qe-v06-` prefix and the `qe-v06-workflows` namespace. Apply the fixture files in the order below; the names are the canonical names used by the steps and expected results.

| Fixture | Objects created | Important values |
|---------|-----------------|------------------|
| [v06-workloads.yaml](resources/v06-workloads.yaml) | Namespace `qe-v06-workflows`; Deployment `qe-v06-web`; DaemonSet `qe-v06-daemon`; Job `qe-v06-job`; CronJob `qe-v06-cron` and its Deployment-owned ReplicaSet | `qe-v06-web` starts at 1 replica and uses `nginx:1.25-alpine`; the completed Job remains visible for manual verification; the CronJob runs every minute |
| [v06-statefulsets.yaml](resources/v06-statefulsets.yaml) | StatefulSet `qe-v06-stateful`; headless Service `qe-v06-stateful`; PVs `qe-v06-stateful-pv-0` and `qe-v06-stateful-pv-1` | Two stable Pods with pre-bound PVCs `qe-v06-stateful-data-qe-v06-stateful-0` and `qe-v06-stateful-data-qe-v06-stateful-1` |
| [v06-logs.yaml](resources/v06-logs.yaml) | Pod `qe-v06-logs`, container `logger` | Emits `qe-v06-log-line` every second |
| [v06-config.yaml](resources/v06-config.yaml) | ResourceQuota `qe-v06-quota`; LimitRange `qe-v06-limits` | Quota limits Pods, CPU requests, and CPU limits; LimitRange defaults are 100m request and 200m limit |
| [v06-config-data.yaml](resources/v06-config-data.yaml) | ConfigMap `qe-v06-config`; Secret `qe-v06-secret`; Pods `qe-v06-config-consumer` and `qe-v06-missing-key` | One Pod proves valid references; the other remains Pending until the missing Secret key is restored |
| [v06-config-recovery.yaml](resources/v06-config-recovery.yaml) | Updated Secret `qe-v06-secret` | Adds `RECOVERY_TOKEN=restored`, allowing the existing pending Pod to start |
| [v06-config-admission.yaml](resources/v06-config-admission.yaml) | Pod `qe-v06-defaulted` | Omits resources so LimitRange admission defaults can be verified in Pod Inspect |
| [v06-config-quota-exceeded.yaml](resources/v06-config-quota-exceeded.yaml) | Rejected Pod `qe-v06-quota-exceeded` | Requests 3 CPU and limits 5 CPU, exceeding `qe-v06-quota` |
| [v06-config-policies.yaml](resources/v06-config-policies.yaml) | Deployment `qe-v06-policy-target`; HPA `qe-v06-hpa`; PDB `qe-v06-pdb`; Lease `qe-v06-lease` | HPA target 80%, min 1/max 3; PDB minAvailable 1; Lease holder `qe-v06-holder`, duration 30s |
| [v06-config-cluster.yaml](resources/v06-config-cluster.yaml) | PriorityClass `qe-v06-priority`; RuntimeClass `qe-v06-runtime`; consumer Pods | Priority value 1000000; runtime handler `runc`; Pods prove both classes are usable |
| [v06-config-webhooks.yaml](resources/v06-config-webhooks.yaml) | MutatingWebhookConfiguration `qe-v06-mutating-webhook`; ValidatingWebhookConfiguration `qe-v06-validating-webhook` | Each has one `CREATE pods` rule and Failure Policy `Ignore`; configuration-only because no admission server is deployed |
| [v06-storage.yaml](resources/v06-storage.yaml) | PersistentVolume `qe-v06-pv`; StorageClass `qe-v06-manual` | PV is 1Gi, `ReadWriteOnce`, `Retain`; StorageClass uses `kubernetes.io/no-provisioner` |
| [v06-storage-pvc.yaml](resources/v06-storage-pvc.yaml) | PersistentVolumeClaim `qe-v06-claim` | Requests 500Mi and explicitly binds to `qe-v06-pv` |
| [v06-access-control.yaml](resources/v06-access-control.yaml) | ServiceAccount `qe-v06-reader`; Role and RoleBinding `qe-v06-reader`; ClusterRole and ClusterRoleBinding `qe-v06-node-reader` | Namespaced role allows Pod `get/list`; cluster role allows Node `get/list` |

When creating an additional ad-hoc object through **Apply YAML**, use a deterministic name such as `test-deployment`, keep it in `qe-v06-workflows`, and remove it before cleanup. Do not reuse the canonical fixture names during an Apply YAML test.

## Setup

```sh
kubectl apply -f resources/v06-workloads.yaml
kubectl apply -f resources/v06-statefulsets.yaml
kubectl apply -f resources/v06-logs.yaml
kubectl apply -f resources/v06-config.yaml
kubectl apply -f resources/v06-config-data.yaml
kubectl apply -f resources/v06-config-policies.yaml
kubectl apply -f resources/v06-config-cluster.yaml
kubectl apply -f resources/v06-config-webhooks.yaml
kubectl apply -f resources/v06-storage.yaml
kubectl apply -f resources/v06-access-control.yaml
```

Select namespace `qe-v06-workflows` in the Dashboard.

## Workload lifecycle

1. Select namespace `qe-v06-workflows`, open Deployments, and verify `qe-v06-web` is Running with 1/1 replicas.
2. Open its details and confirm Summary, Inspect, and Patch are available.
3. Scale it to 3 from the Deployment details page and verify three Pods appear.
4. Delete one owned Pod from the Pods page and verify the Deployment recreates it.
5. Scale back to 1 and verify the extra Pods disappear.
6. Open DaemonSets, inspect `qe-v06-daemon`, delete one owned Pod, and verify it returns to the expected schedulable-node count.
7. Open ReplicaSets, locate the ReplicaSet whose Owner is `qe-v06-web`, and verify the generated ReplicaSet name is not assumed by the test.
8. Delete that owned ReplicaSet and verify the Deployment creates a replacement with Desired=1, Current=1, and Ready=1.
9. Open Jobs, verify `qe-v06-job` reaches 1/1 completion and remains visible, then delete it.
10. Open CronJobs, verify `qe-v06-cron` shows Every minute and a populated Last Scheduled value, suspend it through Patch, verify its state, resume it, and delete it.

## StatefulSet lifecycle

1. Open StatefulSets and verify `qe-v06-stateful` reaches 2/2 ready replicas.
2. Verify Pods `qe-v06-stateful-0` and `qe-v06-stateful-1` and their PVCs are present and Bound.
3. Delete `qe-v06-stateful-0` from the Pods page and verify the same ordinal Pod is recreated with its PVC.

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

Detailed app-only steps are in [WF-11: Configuration & Policies](wf-11-configuration-policies.md) and [WF-12: Webhook Configurations](wf-12-webhook-configurations.md).

1. Open ConfigMaps & Secrets and verify `qe-v06-config` and `qe-v06-secret`. Verify `qe-v06-config-consumer` is Running and `qe-v06-missing-key` is Pending.
2. Apply `v06-config-recovery.yaml` through Apply YAML and verify the existing `qe-v06-missing-key` Pod becomes Running.
3. Verify ResourceQuota `qe-v06-quota` and LimitRange `qe-v06-limits` values in Inspect; Summary only exposes metadata for these resources.
4. Apply `v06-config-admission.yaml`. Verify `qe-v06-defaulted` is Running and Inspect shows request `100m` and limit `200m`.
5. Apply `v06-config-quota-exceeded.yaml`. Verify Apply YAML reports no resource was applied and the Pod is absent. The app does not expose the exact quota rejection text.
6. Verify HPA `qe-v06-hpa` shows `cpu: <unknown>/80%`, min 1, max 3, and 2 replicas when metrics-server is absent. Install metrics-server only for live scaling tests.
7. Verify PDB `qe-v06-pdb` shows current healthy 2, desired healthy 1, allowed disruptions 1, and expected Pods 2. Direct Pod deletion is not an eviction and does not prove PDB enforcement.
8. Verify Lease `qe-v06-lease`, PriorityClass `qe-v06-priority`, RuntimeClass `qe-v06-runtime`, and their consumer Pods. Cluster-scoped Config pages do not show a namespace selector.
9. Verify ServiceAccount `qe-v06-reader` under Config and its binding under Access Control. Permission allow/deny requires a separate token or restricted kubeconfig.
10. Verify both webhook configuration pages show the canonical fixtures, Webhooks 1, and Failure Policy Ignore. Admission behavior requires a reachable TLS webhook server and is not claimed by this fixture.
11. Anonymous RBAC requires a restricted kubeconfig and should be tested separately from the workload namespace.

## Cleanup

```sh
kubectl delete -f resources/v06-storage-pvc.yaml --ignore-not-found
kubectl delete -f resources/v06-storage.yaml
kubectl delete -f resources/v06-config-webhooks.yaml --ignore-not-found
kubectl delete -f resources/v06-config-cluster.yaml --ignore-not-found
kubectl delete -f resources/v06-config-policies.yaml --ignore-not-found
kubectl delete -f resources/v06-config-admission.yaml --ignore-not-found
kubectl delete -f resources/v06-config-data.yaml --ignore-not-found
kubectl delete -f resources/v06-config.yaml
kubectl delete -f resources/v06-access-control.yaml
kubectl delete -f resources/v06-logs.yaml
kubectl delete -f resources/v06-statefulsets.yaml --ignore-not-found
kubectl delete -f resources/v06-workloads.yaml --ignore-not-found
kubectl delete namespace qe-v06-workflows --ignore-not-found
```

Delete only the temporary resources created by these fixtures.
