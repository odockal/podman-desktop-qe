# DaemonSet lifecycle

## Goal

Verify the dashboard shows DaemonSet placement, inspection, Pod recovery, and
cleanup on the multi-node Kind test cluster.

## Prerequisite gate

Use the three-node Kind profile and verify every node is Ready. A single-node
cluster cannot demonstrate node placement behavior.

## Setup

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-compute-daemon
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: test-daemon
  namespace: test-compute-daemon
spec:
  selector:
    matchLabels:
      app: test-daemon
  template:
    metadata:
      labels:
        app: test-daemon
    spec:
      containers:
        - name: daemon
          image: registry.access.redhat.com/ubi9/ubi-minimal:latest
          command: ["sh", "-c", "sleep 3600"]
```

## Dashboard workflow

1. Select `test-compute-daemon` and open **Compute → DaemonSets**.
   `test-daemon` must be Running; Ready and Up-to-date must equal the number
   of eligible nodes.
2. Open the DaemonSet and verify **Summary**, **Inspect**, and **Patch**.
3. In **Pods**, verify each owned Pod is on an eligible node. Delete one owned
   Pod and confirm it is replaced on the same eligible node; Ready returns to
   its initial value.
4. Delete `test-daemon` from **DaemonSets**. Verify it and all owned Pods
   disappear.

## Cleanup

```sh
kubectl delete namespace test-compute-daemon --ignore-not-found
```
