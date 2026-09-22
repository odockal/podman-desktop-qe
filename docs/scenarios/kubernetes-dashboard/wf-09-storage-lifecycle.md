# WF-09: Storage Lifecycle — PV/PVC Binding (New in 0.6.0)

This scenario verifies that PersistentVolume phase transitions (Available → Bound → Released) are reflected live in the Dashboard as PVCs are created and deleted.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the cluster resources:
  ```bash
  kubectl apply -f cluster-resources.yaml
  ```
  Resource file: [cluster-resources.yaml](resources/cluster-resources.yaml)

`pv1` is pre-configured in the file: hostPath, storageClassName=manual, reclaimPolicy=Retain, capacity=1Gi.

## Scenario Steps

### PV Available State

1. **Verify pv1 initial state**  
   Navigate to Persistent Volumes and verify `pv1` shows Phase=**Available**, Capacity=1Gi, Reclaim Policy=Retain, Storage Class=manual.

### Apply PVC and Watch Binding

2. **Create a PVC targeting the manual storage class**  
   ```bash
   kubectl apply -f - <<'EOF'
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: pvc-bind-test
   spec:
     accessModes: [ReadWriteOnce]
     storageClassName: manual
     resources:
       requests:
         storage: 500Mi
   EOF
   ```

3. **Verify PVC reaches Bound state**  
   Navigate to Persistent Volume Claims and verify `pvc-bind-test` appears and its status transitions to **Bound**.

4. **Verify PV transitions to Bound**  
   Navigate to Persistent Volumes and verify `pv1` Phase has changed from Available to **Bound**. The Claim column shows `default/pvc-bind-test`.

### Delete PVC and Watch PV Release

5. **Delete pvc-bind-test via Dashboard**  
   Use the delete action on `pvc-bind-test` on the Persistent Volume Claims page.  
   **Expected:** `pvc-bind-test` disappears from the PVC page.

6. **Verify PV transitions to Released**  
   Navigate to Persistent Volumes and verify `pv1` Phase has changed to **Released**. (reclaimPolicy=Retain means the PV is not deleted, just released.)
