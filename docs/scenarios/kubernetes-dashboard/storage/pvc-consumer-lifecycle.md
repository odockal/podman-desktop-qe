# PVC consumer lifecycle

## Goal

Verify that the default StorageClass dynamically provisions storage only when
a consumer is scheduled, and that a marker on the PVC survives replacement of
that consumer.

## Prerequisite

Open **Storage → Storage Classes**. A default class with a working provisioner
must be present. On the Kind test cluster this is `standard`, with provisioner
`rancher.io/local-path` and volume binding mode `WaitForFirstConsumer`.

## Setup: namespace and pending claim

Paste this YAML into Podman Desktop **Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-storage-workflow
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-storage-claim
  namespace: test-storage-workflow
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 64Mi
```

## Dashboard workflow

1. In **Storage → Storage Classes**, inspect `standard`. Verify its
   provisioner, default flag, reclaim policy, binding mode, and the
   **Summary**, **Inspect**, and **Patch** tabs.
2. In **Storage → Persistent Volume Claims**, select
   `test-storage-workflow`. `test-storage-claim` must show the `standard`
   class, `ReadWriteOnce`, `64Mi`, and `Pending` in details. The list maps this
   phase to its stopped status indicator.
3. Apply this consumer in Podman Desktop:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-storage-consumer
     namespace: test-storage-workflow
   spec:
     containers:
       - name: consumer
         image: registry.access.redhat.com/ubi9/ubi-minimal:latest
         command:
           - /bin/sh
           - -ec
           - |
             test -s /data/marker || echo storage-test > /data/marker
             cat /data/marker
             sleep 3600
         volumeMounts:
           - name: data
             mountPath: /data
     volumes:
       - name: data
         persistentVolumeClaim:
           claimName: test-storage-claim
   ```

4. Open **Compute → Pods** and verify `test-storage-consumer` is `Running`.
   In its logs, record the numeric marker value.
5. Return to **Storage → Persistent Volume Claims**. The claim must be
   `Bound`; inspect its **Summary**, **Inspect**, and **Patch** tabs.
6. Open **Storage → Persistent Volumes**. A dynamically named PV must be
   `Bound`, show class `standard`, capacity `64Mi`, claim
   `test-storage-workflow/test-storage-claim`, `ReadWriteOnce`, and the
   StorageClass reclaim policy.

## Consumer replacement and persistence

1. In **Compute → Pods**, use **Restart** for `test-storage-consumer` and
   confirm the action.
2. Wait for the replacement Pod with the same name to return to `Running`.
3. Open its terminal and run `cat /data/marker`. It must return the marker
   recorded before restart. The PVC and PV must remain `Bound`.

## Cleanup and expected reclaim result

1. Delete `test-storage-consumer` from **Pods**.
2. Delete `test-storage-claim` from **Persistent Volume Claims**.
3. With the Kind `standard` class (`Delete` reclaim policy), verify the claim
   disappears and its dynamically provisioned PV also disappears.
4. Remove the isolated namespace:

   ```sh
   kubectl delete namespace test-storage-workflow --ignore-not-found
   ```

## Expected evidence

- The PVC remains Pending before a consumer exists.
- Creating the consumer makes the Pod Running and binds both the PVC and PV.
- The PV list exposes the claim, class, size, mode, phase, and reclaim policy.
- Restarting the consumer preserves the marker stored on the PVC.
