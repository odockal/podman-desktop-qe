# Live HPA scaling

## Goal

Verify resource metrics reach the dashboard and cause a Deployment to scale
under sustained CPU load.

## Prerequisite gate

Complete the Metrics Server setup in the
[cluster prerequisite guide](../../../cluster-test-prerequisites.md). Run:

```sh
kubectl top nodes
```
Do not apply this YAML or record a result until every node has a CPU and
memory value. An HPA with `cpu: <unknown>` is a failed environment gate, not a
valid dashboard test result.

## Setup

Apply this YAML with `kubectl apply -f -` or Podman Desktop **Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: qe-v06-hpa-verify
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qe-v06-hpa-load
  namespace: qe-v06-hpa-verify
spec:
  replicas: 1
  selector:
    matchLabels:
      app: qe-v06-hpa-load
  template:
    metadata:
      labels:
        app: qe-v06-hpa-load
    spec:
      containers:
        - name: load
          image: busybox:1.36
          command: ["sh", "-c", "while true; do :; done"]
          resources:
            requests:
              cpu: 50m
              memory: 32Mi
            limits:
              cpu: 250m
              memory: 64Mi
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: qe-v06-hpa-live
  namespace: qe-v06-hpa-verify
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: qe-v06-hpa-load
  minReplicas: 1
  maxReplicas: 3
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
```

Wait for the Deployment to become available:

```sh
kubectl -n qe-v06-hpa-verify rollout status deployment/qe-v06-hpa-load --timeout=120s
```

The Deployment begins with one CPU-bound Pod. Its container requests `50m` CPU,
is limited to `250m`, and the HPA target is 60%. The resource names are
`qe-v06-hpa-load` and `qe-v06-hpa-live`.

## Dashboard workflow

1. Open **Config → Horizontal Pod Autoscalers** and select
   `qe-v06-hpa-verify`.
2. Verify `qe-v06-hpa-live` is `Running`; its metric must be numeric and above
   `cpu: 60%/60%`.
3. Verify minimum Pods is `1`, maximum Pods is `3`, and both **Replicas** and
   **Desired** reach `3`.
4. Open **Compute → Deployments** and verify `qe-v06-hpa-load` is Ready `3/3`.
5. Open **Compute → Pods** and verify the three Pods are Running. Return to the
   HPA list and confirm it still shows the numeric metric and desired count.
6. Open the HPA details and check **Summary**, **Inspect**, and **Patch**.

## Expected evidence

- `kubectl top nodes` and the dashboard HPA list both show usable metrics.
- The dashboard lists a CPU value above target, not `<unknown>`.
- The controller changes the Deployment from one to three replicas.

## Cleanup

```sh
kubectl delete namespace qe-v06-hpa-verify --ignore-not-found
```
