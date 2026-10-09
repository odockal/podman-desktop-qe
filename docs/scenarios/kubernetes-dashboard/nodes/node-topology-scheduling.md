# Node topology and scheduling workflow

This workflow validates the Nodes page with the canonical three-node Kind
cluster. It covers inventory, node health data, a reversible label patch, and
the effect of node selection on a workload.

## Prerequisites

- Create the three-node Kind cluster from
  [the cluster prerequisite guide](../../../cluster-test-prerequisites.md).
- Select `kind-kubernetes-dashboard-test` in both Podman Desktop and `kubectl`.
- Confirm every node is Ready:

```sh
kubectl get nodes -o wide
```

The expected topology is one control-plane node and two worker nodes. The
control-plane node has a `NoSchedule` taint; that is expected and must not be
treated as a failure. Before applying the scheduling fixture, verify every node
reports allocatable CPU, memory, and Pods in its Summary. The workflow needs
those resources to place the test workload predictably; it does not require a
fixed numeric capacity because Kind uses the host's available resources.

## 1. Inspect the node inventory

In Podman Desktop, open **Kubernetes → Nodes**. Verify all three nodes show
`Running`, including one `Control Plane` and two `Node` roles. Check the
Internal IP, Kubernetes version, OS, kernel, and age columns. Use search and
Configure Columns once to confirm those list controls work for node data.

Open the control-plane node and verify its Summary contains:

- `ingress-ready: true` in Labels
- `Ready=True` and no memory, disk, or PID pressure
- Internal IP and hostname
- Capacity and Allocatable CPU, memory, and Pod values
- Pod CIDR, provider ID, and the control-plane `NoSchedule` taint

Open **Inspect** and **Patch**. Do not patch the permanent labels or taints in
this step.

## 2. Reversible worker label and targeted workload

Select one worker node (called `<worker-node>` below). In its Patch tab, add a
temporary label:

```yaml
metadata:
  labels:
    test.kubernetes-dashboard.io/placement: worker-a
```

Verify the label appears in Summary and Inspect. Then apply this inline
fixture from a terminal:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-node-workflow
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-node-placement
  namespace: test-node-workflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-node-placement
  template:
    metadata:
      labels:
        app: test-node-placement
    spec:
      nodeSelector:
        test.kubernetes-dashboard.io/placement: worker-a
      containers:
        - name: ubi
          image: registry.access.redhat.com/ubi9/ubi-minimal:latest
          command: ["/bin/sh", "-c", "sleep 3600"]
```

```sh
kubectl apply -f node-placement.yaml
kubectl -n test-node-workflow rollout status deployment/test-node-placement --timeout=120s
kubectl -n test-node-workflow get pod -o wide
```

The Pod must be Running on `<worker-node>`. In Podman Desktop, verify the
Deployment and Pod show the expected node assignment, then return to the
worker Node details and confirm its temporary label remains visible.

## 3. Selector failure and recovery

Patch the Deployment's pod template selector to a value that matches no node:

```yaml
spec:
  template:
    spec:
      nodeSelector:
        test.kubernetes-dashboard.io/placement: missing
```

The replacement Pod must remain Pending. Inspect its scheduling events in
Podman Desktop and verify that the reason identifies the unmatched selector.
Restore the selector to `worker-a`; the Deployment must return to one Running
Pod on `<worker-node>`.

## 4. Cleanup

Delete only the fixture namespace:

```sh
kubectl delete namespace test-node-workflow --wait=true
```

Remove the temporary worker label in the Node Patch tab:

```yaml
metadata:
  labels:
    test.kubernetes-dashboard.io/placement: null
```

Confirm the Pod and Deployment disappear, the temporary label is absent, and
the three baseline nodes remain Running. Do not delete, cordon, drain, or
modify the Kind system nodes.
