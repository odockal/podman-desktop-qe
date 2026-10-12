# Deployment and ReplicaSet lifecycle

## Goal

Verify a Deployment is visible, can scale through the dashboard, recreates a
deleted Pod and a deleted ReplicaSet, and cleans up its owned resources.

## Setup

Apply this YAML with **Compute → Apply YAML** or `kubectl apply -f -`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-compute-deploy
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-web
  namespace: test-compute-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-web
  template:
    metadata:
      labels:
        app: test-web
    spec:
      containers:
        - name: web
          image: registry.access.redhat.com/ubi9/ubi-minimal:latest
          command: ["sh", "-c", "sleep 3600"]
```

## Dashboard workflow

1. Select `test-compute-deploy`, then open **Compute → Deployments**. Verify
   `test-web` reaches `1/1` and is Available.
2. Open its details and verify **Summary**, **Inspect**, and **Patch**.
3. Use **Scale** to set replicas from `1` to `3`. Verify three Running Pods.
4. In **Pods**, delete one Pod owned by `test-web`. Verify a new Pod appears
   and the Deployment returns to `3/3`.
5. Scale back to `1`. In **ReplicaSets**, find the ReplicaSet owned by
   `Deployment/test-web`; verify Desired, Current, and Ready are `1`.
6. Open that ReplicaSet's details, then delete it. Verify the Deployment
   creates a replacement ReplicaSet with a new hash-suffixed name and it
   returns to `1/1/1`.
7. Delete `test-web` through **Deployments**. Verify the Deployment,
   replacement ReplicaSet, and owned Pod disappear.

## Cleanup

```sh
kubectl delete namespace test-compute-deploy --ignore-not-found
```
