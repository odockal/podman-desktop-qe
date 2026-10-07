# Kubernetes Dashboard Extension — Test Scenarios (v0.6.0)

This directory contains manual test scenario docs for the Kubernetes Dashboard Podman Desktop extension v0.6.0 release.

## Section workflow runbooks

These focused runbooks mirror the Dashboard navigation and use meaningful
resource workflows rather than isolated list checks. Start with
[cluster setup and capability gates](setup/README.md) before running a section.

| Section | Runbook index |
| --- | --- |
| Nodes | [Node topology and scheduling](nodes/README.md) |
| Compute | [Compute workflows](compute/README.md) |
| Config | [Config workflows](config/README.md) |
| Network | [Network workflows](network/README.md) |
| Storage | [Storage workflows](storage/README.md) |
| Access Control | [Access Control workflows](access-control/README.md) |
| Namespaces | [Namespace workflows](namespaces/README.md) |

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
shared [cluster prerequisites](../../cluster-test-prerequisites.md).

## Compute functional workflows

The Compute section is organized by controller behavior. Each workflow embeds
its own `test-*` fixtures and uses public Red Hat UBI images:

| Group | Workflow | Prerequisite |
| --- | --- | --- |
| Deployments and ReplicaSets | [Deployment and ReplicaSet lifecycle](compute/deployment-replicaset.md) | Connected cluster and a namespace create permission |
| DaemonSets | [DaemonSet lifecycle](compute/daemonset.md) | Three Ready Kind nodes |
| Jobs and CronJobs | [Job and CronJob lifecycle](compute/jobs-cronjobs.md) | Connected cluster and a namespace create permission |
| StatefulSets | [StatefulSet lifecycle](compute/statefulset.md) | Connected cluster and a namespace create permission |

Start with [Compute workflows](compute/README.md).

## Network functional workflows

The Network section combines Service connectivity with the resources that
explain its backend, policy, and routing behavior. All workflows use inline
`test-*` fixtures and public Red Hat UBI Python images:

| Group | Workflow | Prerequisite |
| --- | --- | --- |
| Service connectivity | [Service and port-forwarding lifecycle](network/service-port-forwarding.md) | Connected cluster and free local port 50000 |
| Service backends and policy | [Endpoints, EndpointSlices, and NetworkPolicy](network/service-endpoints-policy.md) | CNI enforcement for the negative policy check |
| Routing APIs | [Ingress and Gateway API lifecycle](network/ingress-gateway-routing.md) | Ingress/Gateway controller and corresponding APIs installed |

Start with [Network workflows](network/README.md).

## Standalone workflows

| Scenario | File | Description |
|----------|------|-------------|
| WF-01 | [wf-01-extension-setup.md](wf-01-extension-setup.md) | Extension install, enable/disable toggle, kubeconfig connectivity |
| WF-04 | [wf-04-pod-logs-annotations.md](wf-04-pod-logs-annotations.md) | Pod log streaming, timestamp annotation, color annotation |
