# Kubernetes Dashboard test-cluster prerequisites

Use this configuration before executing the Kubernetes Dashboard functional
workflows. It separates baseline coverage from workflows that require an
additional cluster capability.

## 1. Baseline multi-node Kind cluster

Create the canonical three-node cluster:

```sh
kind create cluster --config tests/resources/kind-daemonset-cluster.yaml
kubectl config use-context kind-daemonset-test
kubectl wait --for=condition=Ready node --all --timeout=120s
kubectl get nodes -o wide
```

The Nodes page must show one control-plane node and two worker nodes as
`Ready`. Do not use a single-node cluster for controller, scheduling,
DaemonSet, or node-placement workflows.

Before each run, record the Podman Desktop version, extension version,
Kubernetes version, current context, and fixture namespace. Confirm the
Podman Desktop context matches `kubectl config current-context`.

## 2. Metrics Server for HPA workflows

HPA scale tests require the resource-metrics API. Do not execute an HPA test
if the HPA reports `cpu: <unknown>`.

Install the version verified with this Kind profile:

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.0/components.yaml
kubectl -n kube-system patch deployment metrics-server --type=json \
  --patch='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
```

`--kubelet-insecure-tls` is only for the local Kind test cluster. Its kubelet
certificates do not contain IP SANs, so Metrics Server cannot collect metrics
without this compatibility setting. Do not use it in production.

Only proceed when the APIService is `Available=True` and `kubectl top nodes`
returns a CPU and memory value for every node.

Use [the live HPA scaling workflow](scenarios/kubernetes-dashboard/config/hpa-live-scaling.md) to test live
scaling. Its YAML creates `test-hpa-verify`, where `test-hpa-live` should report
CPU above its 60% target and reach three current and desired replicas.

## 3. Capability gates by workflow

| Workflow area | Required cluster configuration | Do not run when |
| --- | --- | --- |
| Dashboard, Nodes, Pods, Deployments, ReplicaSets, Jobs, CronJobs, DaemonSets | Three Ready Kind nodes and an active matching context | Nodes are missing, NotReady, or a different context is selected |
| ConfigMap, Secret, ServiceAccount, Role, RoleBinding, ResourceQuota, LimitRange, Lease, PDB | Baseline cluster and permission to create fixtures in an isolated namespace | The active context cannot create the required namespaced resources |
| HPA | Metrics Server and successful `kubectl top nodes` | Metrics are unavailable or reported as `<unknown>` |
| Service and port-forward | Baseline cluster; a local free port for the forwarding check | Service has no endpoints or the selected local port is occupied |
| Ingress | Ingress controller, an `IngressClass`, and a route to the controller | The controller or class is absent |
| Gateway API | Gateway API CRDs and a controller with a `GatewayClass` | CRDs, class, or controller are absent |
| PVC and dynamic storage | A default or explicitly named `StorageClass` with a working provisioner | PVC remains Pending |
| Static PV lifecycle | A pre-created PV matching the fixture's storage class, mode, and capacity | No matching PV is Available |
| RuntimeClass workload | A node runtime handler that matches the RuntimeClass handler | The node runtime does not advertise the handler |
| Admission webhook behavior | Reachable TLS webhook Service, CA bundle, and a selector limited to the dedicated test namespace | The Service is unreachable, TLS fails, the selector is omitted, or the fixture uses a placeholder URL |

## 4. Test namespace and cleanup policy

Use one unique namespace per workflow run, such as `test-hpa-verify`.
Do not alter system components or pre-existing workloads when testing resource
behavior. Cluster-scoped fixtures, port forwards, and webhook configurations
need explicit cleanup steps; namespaced fixtures can be removed by deleting
only their dedicated namespace after evidence has been captured.

## 5. CI gates

CI should create the multi-node Kind cluster, install Metrics Server before
the HPA suite, and poll `kubectl top nodes` rather than relying on a fixed
delay. Run prerequisite-dependent suites only after their gate succeeds; mark
a missing capability as an environment setup failure, not an extension result.
