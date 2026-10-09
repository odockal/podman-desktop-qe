# Static PV reclamation

## Goal

Verify the `Retain` reclamation path separately from dynamic provisioning: a
PVC binds to a pre-created PV, and deleting the claim releases rather than
deletes that PV.

## Prerequisite

Use a test cluster where a Pod can run on the node hosting the static volume.
The fixture below pins both the PV and consumer to the Kind control-plane node.
Replace `kubernetes-dashboard-test-control-plane` if the local cluster uses a different
node name.

## Setup

Paste this YAML into Podman Desktop **Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-storage-retain
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: test-storage-retain-pv
spec:
  capacity:
    storage: 64Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: test-static
  hostPath:
    path: /tmp/test-storage-retain
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - kubernetes-dashboard-test-control-plane
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-storage-retain-claim
  namespace: test-storage-retain
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: test-static
  volumeName: test-storage-retain-pv
  resources:
    requests:
      storage: 64Mi
```

## Dashboard workflow

1. In **Storage → Persistent Volumes**, verify `test-storage-retain-pv` is
   `Bound`, has class `test-static`, capacity `64Mi`, reclaim policy `Retain`,
   and references `test-storage-retain/test-storage-retain-claim`.
2. In **Storage → Persistent Volume Claims**, select `test-storage-retain`.
   Verify the claim is `Bound`, then inspect its **Summary**, **Inspect**, and
   **Patch** tabs.
3. Delete `test-storage-retain-claim` from the PVC row action and confirm the
   operation.
4. Return to **Persistent Volumes**. The PV must remain visible with phase
   `Released`; it must not be deleted.

## Cleanup

Delete the remaining cluster-scoped PV after recording evidence:

```sh
kubectl delete persistentvolume test-storage-retain-pv --ignore-not-found
kubectl delete namespace test-storage-retain --ignore-not-found
```

## Expected evidence

- Explicit PVC-to-PV binding is visible in both Storage lists.
- Deleting a claim under `Retain` leaves the PV visible and `Released`.
- The dynamic `Delete` outcome is tested separately, avoiding an ambiguous
  expectation for the default StorageClass.
