# StatefulSet lifecycle

## Goal

Verify stable Pod ordinals, controller reconciliation, scaling, and deletion
for a basic StatefulSet without persistent volumes.

## Setup

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-compute-stateful
---
apiVersion: v1
kind: Service
metadata:
  name: test-stateful
  namespace: test-compute-stateful
spec:
  clusterIP: None
  selector:
    app: test-stateful
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: test-stateful
  namespace: test-compute-stateful
spec:
  serviceName: test-stateful
  replicas: 2
  selector:
    matchLabels:
      app: test-stateful
  template:
    metadata:
      labels:
        app: test-stateful
    spec:
      containers:
        - name: app
          image: registry.access.redhat.com/ubi9/ubi-minimal:latest
          command: ["sh", "-c", "sleep 3600"]
```

## Dashboard workflow

1. Select `test-compute-stateful` and open **Compute → StatefulSets**.
   `test-stateful` must show `2/2` desired/current/ready replicas and Service
   `test-stateful`.
2. Verify **Summary**, **Inspect**, and **Patch**. In **Pods**, confirm
   `test-stateful-0` and `test-stateful-1` are Running.
3. Delete `test-stateful-0`; the controller must recreate the same ordinal
   and return to `2/2` Ready.
4. Patch replicas from `2` to `3`. Verify `test-stateful-2` is created and
   the StatefulSet reaches `3/3`. Delete the StatefulSet and verify its Pods
   disappear.

## Cleanup

```sh
kubectl delete namespace test-compute-stateful --ignore-not-found
```
