# Storage section workflows

These workflows are the source of truth for manual Storage-section release
testing. They verify the Kubernetes relationship between a StorageClass, a
PersistentVolumeClaim (PVC), a PersistentVolume (PV), and a workload rather
than only checking that each resource is listed.

Complete the shared [cluster prerequisites](../../../cluster-test-prerequisites.md)
first. Dynamic provisioning requires a working default StorageClass; the
Retain workflow additionally requires a static PV with `persistentVolumeReclaimPolicy: Retain`.

| Group | Workflow | Resources and outcome | Prerequisite |
| --- | --- | --- | --- |
| Dynamic provisioning | [PVC consumer lifecycle](pvc-consumer-lifecycle.md) | StorageClass → pending PVC → consumer Pod → bound dynamically provisioned PV → marker survives Pod replacement | Default StorageClass and provisioner |
| Retain policy | [Static PV reclamation](static-pv-reclamation.md) | Static PV → explicitly bound PVC → delete claim → PV becomes `Released` | Static PV and `Retain` reclaim policy |

Use only the dedicated `test-storage-*` namespace and resources. Delete the
temporary namespace and any cluster-scoped PV created by the static workflow
when finished.
