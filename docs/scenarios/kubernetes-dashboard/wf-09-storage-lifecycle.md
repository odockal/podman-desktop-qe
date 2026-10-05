# WF-09: Storage Lifecycle — PV/PVC Binding (New in 0.6.0)

This scenario verifies that PersistentVolume phase transitions (Available → Bound → Released) are reflected live in the Dashboard as PVCs are created and deleted.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the storage resources:
  ```bash
  kubectl apply -f resources/v06-storage.yaml
  ```
  Resource file: [v06-storage.yaml](resources/v06-storage.yaml)

`qe-v06-pv` is pre-configured in the file: hostPath, storageClassName=`qe-v06-manual`, reclaimPolicy=Retain, capacity=1Gi.

## Scenario Steps

### PV Available State

1. **Verify qe-v06-pv initial state**
   Navigate to Persistent Volumes and verify `qe-v06-pv` shows Phase=**Available**, Capacity=1Gi, Reclaim Policy=Retain, Storage Class=`qe-v06-manual`.

### Apply PVC and Watch Binding

2. **Create qe-v06-claim targeting the manual storage class**
   ```bash
   kubectl apply -f resources/v06-storage-pvc.yaml
   ```

3. **Verify PVC reaches Bound state**
   Select namespace `qe-v06-workflows`. Navigate to Persistent Volume Claims and verify `qe-v06-claim` appears and its status transitions to **Bound**.

4. **Verify PV transitions to Bound**
   Navigate to Persistent Volumes and verify `qe-v06-pv` Phase has changed from Available to **Bound**. The Claim column shows `qe-v06-workflows/qe-v06-claim`.

### Delete PVC and Watch PV Release

5. **Delete qe-v06-claim via Dashboard**
   Use the delete action on `qe-v06-claim` on the Persistent Volume Claims page.
   **Expected:** `qe-v06-claim` disappears from the PVC page.

6. **Verify PV transitions to Released**
   Navigate to Persistent Volumes and verify `qe-v06-pv` Phase has changed to **Released**. (reclaimPolicy=Retain means the PV is not deleted, just released.)

## Cleanup

```bash
kubectl delete -f resources/v06-storage-pvc.yaml --ignore-not-found
kubectl delete -f resources/v06-storage.yaml --ignore-not-found
```
