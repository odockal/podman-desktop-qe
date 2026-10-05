# WF-11: Configuration & Policies (New in 0.6.0)

This workflow verifies every non-webhook page under **Config** with deterministic resources and app-visible outcomes. Perform navigation, inspection, patch availability checks, and verification in Podman Desktop. Use **Apply YAML** for setup files.

## Prerequisites

- A Kind cluster is connected in Podman Desktop.
- Namespace `qe-v06-workflows` is selected for namespaced pages.
- Apply these fixtures through **Apply YAML**, in order:

  1. [v06-config.yaml](resources/v06-config.yaml) — ResourceQuota `qe-v06-quota` and LimitRange `qe-v06-limits`.
  2. [v06-config-data.yaml](resources/v06-config-data.yaml) — ConfigMap `qe-v06-config`, Secret `qe-v06-secret`, and consumer Pods.
  3. [v06-config-policies.yaml](resources/v06-config-policies.yaml) — Deployment `qe-v06-policy-target`, HPA `qe-v06-hpa`, PDB `qe-v06-pdb`, and Lease `qe-v06-lease`.
  4. [v06-config-cluster.yaml](resources/v06-config-cluster.yaml) — PriorityClass `qe-v06-priority`, RuntimeClass `qe-v06-runtime`, and one consumer Pod for each.
  5. [v06-access-control.yaml](resources/v06-access-control.yaml) — ServiceAccount `qe-v06-reader` and its RBAC resources.

The functional checks below are proposed manual tests. They are intentionally not marked verified until run against the target cluster.

## ConfigMaps & Secrets

1. Open **Config → ConfigMaps & Secrets**.
2. Verify `qe-v06-config` has Type `ConfigMap` and one key. Open it and verify `APP_MODE=dashboard` in Summary.
3. Verify `qe-v06-secret` has Type `Opaque` and initially one key. Verify the `API_TOKEN` key is present; decoding or displaying its value is not required.
4. Open **Pods** and verify `qe-v06-config-consumer` is Running. Its readiness proves that both referenced values are available and correct.
5. Verify `qe-v06-missing-key` is Pending because `RECOVERY_TOKEN` does not exist.
6. Apply [v06-config-recovery.yaml](resources/v06-config-recovery.yaml) through **Apply YAML**.

**Expected:** the existing `qe-v06-missing-key` Pod becomes Running without recreation, and `qe-v06-secret` now reports two keys.

### Config update and recovery (proposed)

1. Apply [v06-config-invalid-token.yaml](resources/v06-config-invalid-token.yaml) through **Apply YAML**.
2. Delete Pod `qe-v06-config-consumer` from the Pods page, confirm the deletion, then apply [v06-config-consumer.yaml](resources/v06-config-consumer.yaml).
3. Verify the recreated Pod does not become Ready because its `API_TOKEN` is invalid.
4. Apply [v06-config-valid-token.yaml](resources/v06-config-valid-token.yaml), delete the failed Pod, and apply `v06-config-consumer.yaml` again.

**Expected:** the same consumer definition fails with the invalid Secret value and becomes Running only after the correct value is restored. This proves the referenced Secret value, not only the resource list entry, controls the workload.

## ResourceQuota & LimitRange

1. Open **Config → Resource Quotas** and verify `qe-v06-quota` is listed.
2. Open **Inspect** and verify hard limits `pods=10`, `requests.cpu=2`, and `limits.cpu=4`. Summary contains metadata; quota values are verified in Inspect.
3. Open **Config → Limit Ranges** and verify `qe-v06-limits` has Type `Container` and Count `1`.
4. Open **Inspect** and verify default request `100m` and default limit `200m`.
5. Apply [v06-config-admission.yaml](resources/v06-config-admission.yaml). Open Pod `qe-v06-defaulted` and verify it is Running and has QoS `Burstable`.
6. In the Pod's **Inspect** tab, verify `resources.requests.cpu=100m` and `resources.limits.cpu=200m`.
7. Apply [v06-config-quota-exceeded.yaml](resources/v06-config-quota-exceeded.yaml).

**Expected:** Podman Desktop reports that no resource was applied, and `qe-v06-quota-exceeded` does not appear on the Pods page. The current Apply YAML result does not expose the Kubernetes quota rejection text, so the test asserts rejection and absence rather than an exact error message.

### ResourceQuota usage (proposed)

1. In `qe-v06-quota` **Inspect**, record the current `status.used` values for Pods, CPU requests, and CPU limits.
2. Apply [v06-config-quota-usage.yaml](resources/v06-config-quota-usage.yaml), then verify Pod `qe-v06-quota-usage` is Running.
3. Refresh `qe-v06-quota` **Inspect** and verify the used Pod count increases by `1`, CPU requests by `100m`, and CPU limits by `200m`.
4. Delete `qe-v06-quota-usage` from the Pods page, confirm the deletion, then refresh the quota until those values return to the recorded baseline.

**Expected:** quota usage reflects a real workload create and delete cycle, not only configured hard limits.

## Horizontal Pod Autoscaler

1. Open **Config → Horizontal Pod Autoscalers**.
2. Verify `qe-v06-hpa` shows Metrics `cpu: <unknown>/80%`, Min Pods `1`, Max Pods `3`, and Replicas `2` when metrics-server is not installed.
3. Open details and verify Summary, Inspect, and Patch are available. Use Inspect to verify the target Deployment is `qe-v06-policy-target`.

**Expected:** configuration visibility passes without metrics-server. Live CPU-driven scaling is tested only when metrics-server is installed; otherwise `<unknown>` is the predictable result and is not a failure.

### CPU-driven HPA scaling (proposed; requires metrics-server)

1. Confirm metrics-server is installed and `qe-v06-hpa` no longer reports `<unknown>`.
2. Apply [v06-config-hpa-load.yaml](resources/v06-config-hpa-load.yaml).
3. Open `qe-v06-hpa-load` and wait for the CPU metric to exceed the `60%` target.
4. Verify the desired and current replica counts increase above `1`, up to the configured maximum of `3`.
5. Delete the load Deployment and HPA when the test is complete.

**Expected:** the HPA page reports a known CPU metric and the target Deployment scales beyond one replica. Do not run this test where metrics-server is unavailable.

## Pod Disruption Budget

1. Open **Config → Pod Disruption Budgets**.
2. Verify `qe-v06-pdb` shows Min Available `1`, Current Healthy `2`, Desired Healthy `1`, Allowed Disruptions `1`, and Expected Pods `2`.
3. Open Inspect and verify the selector targets `app=qe-v06-policy-target`.

**Important:** PDBs govern voluntary evictions through the Kubernetes Eviction API. The Dashboard offers **Delete Pod**, not **Evict Pod**; direct deletion bypasses the PDB and must not be used as a PDB enforcement test.

### PDB status reaction (proposed)

1. Open **Compute → Deployments**, open `qe-v06-policy-target`, and use **Patch** to set `spec.replicas` to `1`.
2. Wait for the Deployment to report one available replica, then refresh `qe-v06-pdb`.
3. Verify Current Healthy and Desired Healthy are `1`, Expected Pods is `1`, and Allowed Disruptions is `0`.
4. Patch the Deployment back to `spec.replicas: 2` and verify the initial PDB counters return.

**Expected:** the PDB status follows the selected workload's replica count. This remains a status test; Dashboard does not offer the Eviction API needed to test PDB enforcement.

## Lease

1. Open **Config → Leases**.
2. Verify `qe-v06-lease` shows Holder `qe-v06-holder`, Lease Duration `30s`, and Renew Time `2026-10-05T12:00:00.000Z`.
3. Open details and verify Summary, Inspect, and Patch are available. Verify the same spec values in Inspect.

### Lease update (proposed)

1. Use **Patch** to change `spec.holderIdentity` to `qe-v06-patched` and `spec.renewTime` to a later RFC 3339 timestamp.
2. Verify the Lease list and Inspect tab show the new holder and renew time.
3. Patch the values back to `qe-v06-holder` and `2026-10-05T12:00:00.000000Z`.

**Expected:** the list and details refresh after a Lease patch and show the persisted values.

## PriorityClass

1. Open **Config → Priority Classes**. This page is cluster-scoped and does not show a namespace selector.
2. Verify `qe-v06-priority` shows Value `1000000`, Global Default `false`, and Preemption Policy `PreemptLowerPriority`.
3. Open **Pods** in `qe-v06-workflows` and verify `qe-v06-priority-pod` is Running.
4. Open the Pod's Inspect tab and verify `priorityClassName=qe-v06-priority`.

## RuntimeClass

1. Open **Config → Runtime Classes**. This page is cluster-scoped and does not show a namespace selector.
2. Verify `qe-v06-runtime` shows Handler `runc`.
3. Open **Pods** in `qe-v06-workflows` and verify `qe-v06-runtime-pod` is Running.
4. Open the Pod's Inspect tab and verify `runtimeClassName=qe-v06-runtime`.

## ServiceAccount

1. Open **Config → Service Accounts** and verify `qe-v06-reader` is Running with zero Secrets.
2. Open details and verify Summary, Inspect, and Patch are available.
3. Open **Access Control → Role Bindings** and verify RoleBinding `qe-v06-reader` references ServiceAccount `qe-v06-reader` and Role `qe-v06-reader`.

**Expected:** the Config page proves the ServiceAccount exists; its permissions are verified through the related Access Control resources.

### ServiceAccount authorization (proposed)

1. Apply [v06-config-rbac-check.yaml](resources/v06-config-rbac-check.yaml) through **Apply YAML**.
2. Verify Pod `qe-v06-rbac-check` is Running.
3. Open its logs and verify `pods=200 configmaps=403`.

**Expected:** the mounted ServiceAccount token can list Pods through the RoleBinding but is denied access to ConfigMaps, which are not granted by either RBAC role. This is a functional allow/deny test without exposing the token in the app.

## Cleanup

```sh
kubectl delete -f resources/v06-config-cluster.yaml --ignore-not-found
kubectl delete -f resources/v06-config-policies.yaml --ignore-not-found
kubectl delete -f resources/v06-config-hpa-load.yaml --ignore-not-found
kubectl delete -f resources/v06-config-admission.yaml --ignore-not-found
kubectl delete -f resources/v06-config-rbac-check.yaml --ignore-not-found
kubectl delete -f resources/v06-config-quota-usage.yaml --ignore-not-found
kubectl delete -f resources/v06-config-consumer.yaml --ignore-not-found
kubectl delete -f resources/v06-config-data.yaml --ignore-not-found
kubectl delete -f resources/v06-config.yaml --ignore-not-found
kubectl delete -f resources/v06-access-control.yaml --ignore-not-found
```
