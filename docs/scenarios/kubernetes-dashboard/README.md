# Kubernetes Dashboard Extension — Test Scenarios (v0.6.0)

This directory contains manual test scenario docs for the Kubernetes Dashboard Podman Desktop extension v0.6.0 release.

## Resource Files

YAML fixtures used across scenarios are in the [`resources/`](resources/) subdirectory:

| File | Contents and exact object names | Used In |
|------|----------|---------|
| [cluster-resources.yaml](resources/cluster-resources.yaml) | General resource catalog for exploratory testing: `deploy1`, `deploy2`, `deploy3`; `pod1`, `pod2`, `pod3`; `svc1-clusterip`–`svc4-nodeport`; `ingress1`; `pvc1`; `configmap1`; `secret1-generic`–`secret3-tls`; `job1`; `cronjob1`; `daemonset1`, `daemonset2`; `replicaset1`, `replicaset2`; `pv1`; `storage-class1`; `endpoint1`; `network-policy1`; `ingress-class1`; `gateway-class1`; `gateway1`; `httproute1` | Exploratory use |
| [access-control.yaml](resources/access-control.yaml) | General RBAC and EndpointSlice catalog: `test-sa`, `test-role`, `test-rolebinding`, `test-clusterrole`, `test-clusterrolebinding`, `test-quota`, `test-endpointslice` | Exploratory use |
| [pr-tests.yaml](resources/pr-tests.yaml) | Legacy PR resource catalog: `web`, `mem-limit`, `web-hpa`, `web-pdb`, `high-priority`, `sample-runc`, `sample-lease`, `sample-mwc` | Exploratory use |
| [pr-1226-validating-webhook.yaml](resources/pr-1226-validating-webhook.yaml) | Legacy `sample-vwc` ValidatingWebhookConfiguration | Exploratory use |

> **Kind cluster note:** `cluster-resources.yaml` contains Node objects designed for the envtest fixture. On Kind, skip applying Node resources — Kind manages its own node(s).

## Config functional workflows

The Config section is maintained as a functional suite rather than a list of
independent resource checks. Its workflows embed the exact YAML used by each
scenario and state the prerequisite gate before the test steps:

| Group | Workflow | Prerequisite |
| --- | --- | --- |
| Configuration | [ConfigMap and Secret dependency lifecycle](config/configuration-dependencies.md) | Dedicated namespace and permission to create workloads |
| Policy | [Resource policy and disruption lifecycle](config/resource-policy-pdb.md) | Dedicated namespace and permission to create workloads |
| Scaling | [Live HPA scaling](config/hpa-live-scaling.md) | Metrics Server and numeric `kubectl top nodes` output |
| Access and scheduling | [Access and scheduling](config/access-scheduling.md) | RuntimeClass handler exists when testing workload scheduling |
| Admission control | [Admission webhook lifecycle](config/admission-webhooks.md) | TLS server, CA bundle, and namespace-scoped selector |

Start with [Config workflows and prerequisites](config/README.md) and the
shared [cluster prerequisites](../../cluster-test-prerequisites.md). The
legacy WF-11 and WF-12 documents below are retained for history; use the Config
workflows for release testing.

## Compute functional workflows

The Compute section is organized by controller behavior. Each workflow embeds
its own `test-*` fixtures and uses public Red Hat UBI images:

| Group | Workflow | Prerequisite |
| --- | --- | --- |
| Deployments and ReplicaSets | [Deployment and ReplicaSet lifecycle](compute/deployment-replicaset.md) | Connected cluster and a namespace create permission |
| DaemonSets | [DaemonSet lifecycle](compute/daemonset.md) | Three Ready Kind nodes |
| Jobs and CronJobs | [Job and CronJob lifecycle](compute/jobs-cronjobs.md) | Connected cluster and a namespace create permission |
| StatefulSets | [StatefulSet lifecycle](compute/statefulset.md) | Connected cluster and a namespace create permission |

Start with [Compute workflows](compute/README.md). The legacy WF-02 document
is retained for history; use these grouped workflows for release testing.

## Network functional workflows

The Network section combines Service connectivity with the resources that
explain its backend and policy behavior. Both workflows use inline `test-*`
fixtures and public Red Hat UBI Python images:

| Group | Workflow | Prerequisite |
| --- | --- | --- |
| Service connectivity | [Service and port-forwarding lifecycle](network/service-port-forwarding.md) | Connected cluster and free local port 50000 |
| Service backends and policy | [Endpoints, EndpointSlices, and NetworkPolicy](network/service-endpoints-policy.md) | CNI enforcement for the negative policy check |

Start with [Network workflows](network/README.md). The legacy WF-05 and WF-07
documents are retained for history; use these grouped workflows for release
testing.

## Other scenarios

| Scenario | File | Description |
|----------|------|-------------|
| WF-01 | [wf-01-extension-setup.md](wf-01-extension-setup.md) | Extension install, enable/disable toggle, kubeconfig connectivity |
| WF-02 | [Compute functional workflows](compute/README.md) | Deployments, ReplicaSets, DaemonSets, Jobs, CronJobs, and StatefulSets |
| WF-03 | [wf-03-namespace-filtering.md](wf-03-namespace-filtering.md) | Namespace selector filtering across all workload pages |
| WF-04 | [wf-04-pod-logs-annotations.md](wf-04-pod-logs-annotations.md) | Pod log streaming, timestamp annotation, color annotation |
| WF-05 | [Service and port-forwarding lifecycle](network/service-port-forwarding.md) | Service endpoints, local HTTP connectivity, selector failure, and recovery |
| WF-06 | [wf-06-ingress-routing.md](wf-06-ingress-routing.md) | Ingress routing end-to-end HTTP; verify traffic stops after deletion |
| WF-07 | [Endpoints, EndpointSlices, and NetworkPolicy](network/service-endpoints-policy.md) | Service backend discovery and policy configuration with a CNI gate |
| WF-08 | [wf-08-gateway-api.md](wf-08-gateway-api.md) | Gateway API: GatewayClass, Gateway, HTTPRoute — create and delete |
| WF-09 | [wf-09-storage-lifecycle.md](wf-09-storage-lifecycle.md) | PV/PVC binding lifecycle: Available → Bound → Released |
| WF-10 | [wf-10-access-control-crud.md](wf-10-access-control-crud.md) | RBAC CRUD: Roles, RoleBindings, ClusterRoles, ClusterRoleBindings |
| WF-11 | [Config functional workflows](config/README.md) | ConfigMap/Secret dependencies, policy, live HPA scaling, and access/scheduling |
| WF-12 | [Admission webhook lifecycle](config/admission-webhooks.md) | Scoped TLS webhook mutation and rejection of Pods |
| WF-13 | [wf-13-anonymous-user-rbac.md](wf-13-anonymous-user-rbac.md) | Anonymous kubeconfig: all pages show "Not accessible", no data leaked |

## Verified Podman Desktop workflow fixtures

The following fixtures and runbook were used to verify the workflows against a connected Kind cluster. They keep the setup isolated in `qe-v06-workflows` and separate the PV/PVC binding step so the initial `Available` state can be observed:

| File | Purpose |
|------|---------|
| [verified-workflows.md](verified-workflows.md) | Manual Podman Desktop steps, observed results, prerequisites, and cleanup |
| [v06-workloads.yaml](resources/v06-workloads.yaml) | Namespace, Deployment, DaemonSet, Job, CronJob, and the Deployment-owned ReplicaSet created by Kubernetes |
| [v06-statefulsets.yaml](resources/v06-statefulsets.yaml) | StatefulSet `qe-v06-stateful`, headless Service `qe-v06-stateful`, and two pre-bound PVC/PV pairs |
| [v06-logs.yaml](resources/v06-logs.yaml) | Streaming log Pod used by the logs workflow |
| [v06-config.yaml](resources/v06-config.yaml) | ResourceQuota and LimitRange |
| [v06-config-data.yaml](resources/v06-config-data.yaml) | ConfigMap, Secret, valid consumer Pod, and missing-key Pod |
| [v06-config-recovery.yaml](resources/v06-config-recovery.yaml) | Secret update that recovers the missing-key Pod |
| [v06-config-admission.yaml](resources/v06-config-admission.yaml) | Pod without resource values for LimitRange defaulting |
| [v06-config-quota-exceeded.yaml](resources/v06-config-quota-exceeded.yaml) | Pod request that is predictably rejected by ResourceQuota |
| [v06-config-quota-usage.yaml](resources/v06-config-quota-usage.yaml) | Small, bounded Pod used to verify ResourceQuota `status.used` updates |
| [v06-config-invalid-token.yaml](resources/v06-config-invalid-token.yaml) | Secret update that deliberately makes the Config/Secret consumer fail |
| [v06-config-valid-token.yaml](resources/v06-config-valid-token.yaml) | Secret update that restores the required Config/Secret consumer value |
| [v06-config-consumer.yaml](resources/v06-config-consumer.yaml) | Standalone recreation fixture for Pod `qe-v06-config-consumer` |
| [v06-config-policies.yaml](resources/v06-config-policies.yaml) | HPA target Deployment, HPA, PDB, and Lease |
| [v06-config-hpa-load.yaml](resources/v06-config-hpa-load.yaml) | CPU load Deployment and HPA for the optional metrics-server scaling test |
| [v06-config-cluster.yaml](resources/v06-config-cluster.yaml) | PriorityClass, RuntimeClass, and consumer Pods |
| [v06-config-webhooks.yaml](resources/v06-config-webhooks.yaml) | Safe configuration-only mutating and validating webhook fixtures |
| [v06-storage.yaml](resources/v06-storage.yaml) | PersistentVolume and StorageClass setup |
| [v06-storage-pvc.yaml](resources/v06-storage-pvc.yaml) | Separate PVC binding step |
| [v06-access-control.yaml](resources/v06-access-control.yaml) | ServiceAccount, Role, RoleBinding, ClusterRole, and ClusterRoleBinding |
| [v06-config-rbac-check.yaml](resources/v06-config-rbac-check.yaml) | ServiceAccount-backed Pod that proves allowed Pod listing and denied ConfigMap listing |
| [v06-namespace-filtering.yaml](resources/v06-namespace-filtering.yaml) | Workload objects in `default` and `qe-v06-ns2` for selector isolation |
| [v06-port-forwarding.yaml](resources/v06-port-forwarding.yaml) | Pod `qe-v06-port` and Service `qe-v06-port-svc` |
| [v06-ingress.yaml](resources/v06-ingress.yaml) | Deployment `qe-v06-hello`, Service `qe-v06-hello-svc`, Ingress `qe-v06-hello-ingress` |
| [v06-network.yaml](resources/v06-network.yaml) | Service `qe-v06-network-svc`, Endpoints `qe-v06-network-endpoint`, EndpointSlice `qe-v06-network-slice`, NetworkPolicy `qe-v06-network-policy` |
| [v06-gateway-api.yaml](resources/v06-gateway-api.yaml) | GatewayClass `qe-v06-gateway-class`, Gateway `qe-v06-gateway`, HTTPRoute `qe-v06-http-route`, and backend Service `qe-v06-gateway-svc` |

The current extension places Service Accounts under **Config**, while Roles and RoleBindings are under **Access Control**. HPA live scaling requires metrics-server; without it, the expected metric is `<unknown>/80%`. Webhook admission requires a reachable TLS webhook server, so the supplied webhook fixtures test configuration display rather than mutation or rejection. PDB enforcement requires the Eviction API; direct Pod deletion is not an eviction. Gateway API requires its CRDs and controller. The functional cases labelled **proposed** are not verified results; run them before marking their sheet rows as passed. Use the exact names in these tables when following the scenarios; do not substitute names without updating the expected results.
