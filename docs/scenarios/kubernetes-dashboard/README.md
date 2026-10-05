# Kubernetes Dashboard Extension — Test Scenarios (v0.6.0)

This directory contains manual test scenario docs for the Kubernetes Dashboard Podman Desktop extension v0.6.0 release.

## Resource Files

YAML fixtures used across scenarios are in the [`resources/`](resources/) subdirectory:

| File | Contents and exact object names | Used In |
|------|----------|---------|
| [cluster-resources.yaml](resources/cluster-resources.yaml) | General resource catalog for exploratory testing: `deploy1`, `deploy2`, `deploy3`; `pod1`, `pod2`, `pod3`; `svc1-clusterip`–`svc4-nodeport`; `ingress1`; `pvc1`; `configmap1`; `secret1-generic`–`secret3-tls`; `job1`; `cronjob1`; `daemonset1`, `daemonset2`; `replicaset1`, `replicaset2`; `pv1`; `storage-class1`; `endpoint1`; `network-policy1`; `ingress-class1`; `gateway-class1`; `gateway1`; `httproute1` | Exploratory use |
| [access-control.yaml](resources/access-control.yaml) | General RBAC and EndpointSlice catalog: `test-sa`, `test-role`, `test-rolebinding`, `test-clusterrole`, `test-clusterrolebinding`, `test-quota`, `test-endpointslice` | Exploratory use |
| [pr-tests.yaml](resources/pr-tests.yaml) | `web`, `mem-limit`, `web-hpa`, `web-pdb`, `high-priority`, `sample-runc`, `sample-lease`, `sample-mwc` | WF-11, WF-12 |
| [pr-1226-validating-webhook.yaml](resources/pr-1226-validating-webhook.yaml) | `sample-vwc` ValidatingWebhookConfiguration | WF-12 |

> **Kind cluster note:** `cluster-resources.yaml` contains Node objects designed for the envtest fixture. On Kind, skip applying Node resources — Kind manages its own node(s).

## Scenarios

| Scenario | File | Description |
|----------|------|-------------|
| WF-01 | [wf-01-extension-setup.md](wf-01-extension-setup.md) | Extension install, enable/disable toggle, kubeconfig connectivity |
| WF-02 | [wf-02-workload-lifecycle.md](wf-02-workload-lifecycle.md) | Deploy, scale, self-heal, delete; DaemonSets, ReplicaSets, Jobs, CronJobs |
| WF-03 | [wf-03-namespace-filtering.md](wf-03-namespace-filtering.md) | Namespace selector filtering across all workload pages |
| WF-04 | [wf-04-pod-logs-annotations.md](wf-04-pod-logs-annotations.md) | Pod log streaming, timestamp annotation, color annotation |
| WF-05 | [wf-05-port-forwarding.md](wf-05-port-forwarding.md) | Port forwarding for pods and services; real HTTP connectivity |
| WF-06 | [wf-06-ingress-routing.md](wf-06-ingress-routing.md) | Ingress routing end-to-end HTTP; verify traffic stops after deletion |
| WF-07 | [wf-07-service-endpoints-network-policy.md](wf-07-service-endpoints-network-policy.md) | Service details, live endpoint update, EndpointSlice, NetworkPolicy delete |
| WF-08 | [wf-08-gateway-api.md](wf-08-gateway-api.md) | Gateway API: GatewayClass, Gateway, HTTPRoute — create and delete |
| WF-09 | [wf-09-storage-lifecycle.md](wf-09-storage-lifecycle.md) | PV/PVC binding lifecycle: Available → Bound → Released |
| WF-10 | [wf-10-access-control-crud.md](wf-10-access-control-crud.md) | RBAC CRUD: Roles, RoleBindings, ClusterRoles, ClusterRoleBindings |
| WF-11 | [wf-11-configuration-policies.md](wf-11-configuration-policies.md) | LimitRange, ResourceQuota, HPA, PDB, PriorityClass, RuntimeClass, Lease |
| WF-12 | [wf-12-webhook-configurations.md](wf-12-webhook-configurations.md) | MutatingWebhookConfig and ValidatingWebhookConfig — view and delete |
| WF-13 | [wf-13-anonymous-user-rbac.md](wf-13-anonymous-user-rbac.md) | Anonymous kubeconfig: all pages show "Not accessible", no data leaked |

## Verified Podman Desktop workflow fixtures

The following fixtures and runbook were used to verify the workflows against a connected Kind cluster. They keep the setup isolated in `qe-v06-workflows` and separate the PV/PVC binding step so the initial `Available` state can be observed:

| File | Purpose |
|------|---------|
| [verified-workflows.md](verified-workflows.md) | Manual Podman Desktop steps, observed results, prerequisites, and cleanup |
| [v06-workloads.yaml](resources/v06-workloads.yaml) | Namespace, Deployment, DaemonSet, ReplicaSet, Job, and CronJob |
| [v06-statefulsets.yaml](resources/v06-statefulsets.yaml) | StatefulSet `qe-v06-stateful`, headless Service `qe-v06-stateful`, and two pre-bound PVC/PV pairs |
| [v06-logs.yaml](resources/v06-logs.yaml) | Streaming log Pod used by the logs workflow |
| [v06-config.yaml](resources/v06-config.yaml) | ResourceQuota and LimitRange |
| [v06-storage.yaml](resources/v06-storage.yaml) | PersistentVolume and StorageClass setup |
| [v06-storage-pvc.yaml](resources/v06-storage-pvc.yaml) | Separate PVC binding step |
| [v06-access-control.yaml](resources/v06-access-control.yaml) | ServiceAccount, Role, RoleBinding, ClusterRole, and ClusterRoleBinding |
| [v06-namespace-filtering.yaml](resources/v06-namespace-filtering.yaml) | Workload objects in `default` and `qe-v06-ns2` for selector isolation |
| [v06-port-forwarding.yaml](resources/v06-port-forwarding.yaml) | Pod `qe-v06-port` and Service `qe-v06-port-svc` |
| [v06-ingress.yaml](resources/v06-ingress.yaml) | Deployment `qe-v06-hello`, Service `qe-v06-hello-svc`, Ingress `qe-v06-hello-ingress` |
| [v06-network.yaml](resources/v06-network.yaml) | Service `qe-v06-network-svc`, Endpoints `qe-v06-network-endpoint`, EndpointSlice `qe-v06-network-slice`, NetworkPolicy `qe-v06-network-policy` |
| [v06-gateway-api.yaml](resources/v06-gateway-api.yaml) | GatewayClass `qe-v06-gateway-class`, Gateway `qe-v06-gateway`, HTTPRoute `qe-v06-http-route`, and backend Service `qe-v06-gateway-svc` |

The current extension places Service Accounts under **Config**, while Roles and RoleBindings are under **Access Control**. HPA live scaling requires metrics-server; webhook admission requires a reachable webhook server; Gateway API requires its CRDs and controller. Use the exact names in these tables when following the scenarios; do not substitute names without updating the expected results.
