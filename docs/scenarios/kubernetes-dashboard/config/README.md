# Config section workflows

These workflows are the source of truth for manual Config-section release
testing. Each document combines related resources with a visible Kubernetes
result; it is not a list-only check.

Run the commands from the repository root. First complete the shared
[cluster prerequisites](../../../cluster-test-prerequisites.md). In particular,
do not start the HPA workflow until `kubectl top nodes` returns data.

| Group | Workflow | Resources and outcome | Prerequisite |
| --- | --- | --- | --- |
| Configuration | [Configuration dependencies](configuration-dependencies.md) | ConfigMap and Secret consumers, failure after invalid data, and recovery | Dedicated namespace and permission to create workloads |
| Policy | [Resource policy and disruption](resource-policy-pdb.md) | LimitRange defaults, ResourceQuota admission/usage, and PDB counters | Dedicated namespace and permission to create workloads |
| Scaling | [Live HPA scaling](hpa-live-scaling.md) | Metrics-backed CPU load causes a Deployment to scale from one to three Pods | Metrics Server and numeric `kubectl top nodes` output |
| Access and scheduling | [Access and scheduling](access-scheduling.md) | ServiceAccount/RBAC authorization, Lease refresh, PriorityClass, and RuntimeClass | RuntimeClass handler exists when testing workload scheduling |
| Admission control | [Admission webhooks](admission-webhooks.md) | TLS-backed mutation and rejection of Pods | TLS server, CA bundle, and namespace-scoped selector |

Each YAML definition uses a `qe-v06-*` name. Keep the workflow namespaces
isolated and delete only those namespaces or cluster-scoped objects listed in
that workflow's cleanup section.
