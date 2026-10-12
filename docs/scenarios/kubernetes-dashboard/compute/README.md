# Compute workflows

These functional workflows test Kubernetes controllers through the Podman
Desktop dashboard. Each uses `test-*` names, embeds its YAML, and leaves the
cluster unchanged outside its own namespace.

Complete the shared [cluster prerequisites](../../../cluster-test-prerequisites.md)
first. DaemonSet placement needs the three-node Kind cluster; all other
workflows need a connected cluster and permission to create resources.

| Group | Workflow | Result |
| --- | --- | --- |
| Deployments | [Deployment and ReplicaSet lifecycle](deployment-replicaset.md) | Scale, self-heal, inspect, and deletion cascade |
| DaemonSets | [DaemonSet lifecycle](daemonset.md) | One Pod per eligible node and controller reconciliation |
| Batch | [Job and CronJob lifecycle](jobs-cronjobs.md) | Completion, scheduling, suspend/resume, and deletion |
| StatefulSets | [StatefulSet lifecycle](statefulset.md) | Stable ordinal recovery and replica changes without PVCs |

All workload containers use public Red Hat UBI images. Do not mark a case
passed only because the resource appears in a list: perform the associated
controller behavior and capture its dashboard-visible result.
