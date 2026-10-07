# Cluster setup and capability gates

This section is the entry point for preparing a local cluster before executing
the Kubernetes Dashboard release workflows. The complete, command-by-command
procedure is the [shared cluster prerequisite guide](../../../cluster-test-prerequisites.md).

## Baseline setup

1. Save the following Kind configuration as `kind-daemonset-cluster.yaml` and
   create the canonical three-node `daemonset-test` cluster.
2. Select `kind-daemonset-test` in both `kubectl` and Podman Desktop, then
   wait until the control plane and both workers are `Ready`.
3. Keep host ports `9090` and `9443` free; the profile maps them to the
   control-plane node for Ingress and Gateway traffic checks.
4. Record the Podman Desktop version, Dashboard extension version, current
   Kubernetes context, and fixture namespace before each run.

## Kind configuration

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: daemonset-test
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 9090
        protocol: TCP
      - containerPort: 443
        hostPort: 9443
        protocol: TCP
  - role: worker
  - role: worker
```

Create and validate the cluster:

```sh
kind create cluster --config kind-daemonset-cluster.yaml
kubectl config use-context kind-daemonset-test
kubectl wait --for=condition=Ready node --all --timeout=120s
kubectl get nodes -o wide
```

In Podman Desktop, make sure the Kubernetes context shown by the Dashboard is
also `kind-daemonset-test`. The expected inventory is one control plane and
two workers.

## Capability gates

| Workflow area | Required before execution | Treat as an environment blocker when |
| --- | --- | --- |
| Nodes and DaemonSets | One Ready control plane and two Ready workers | Any node is missing or NotReady |
| Compute, Config, Access Control, Namespaces | Active matching context and permission to create `test-*` resources | The active identity cannot create the fixture namespace/resources |
| HPA live scaling | Metrics Server is Available and `kubectl top nodes` returns numbers | CPU metrics are `<unknown>` |
| Services and port-forwarding | A free local forwarding port and ready Service endpoints | The Service has no endpoints or the port is occupied |
| Ingress | Ready controller, managed IngressClass, controller Pod on the mapped node | A real request through `localhost:9090` fails |
| Gateway API | Gateway CRDs, controller, and a Gateway with `Accepted=True` and `Programmed=True` | API resources or programmed controller state are absent |
| Dynamic PVC lifecycle | A default StorageClass with a working provisioner | The PVC remains Pending after the consumer starts |
| Static PV lifecycle | An Available PV matching the fixture class, capacity, and access mode | No matching PV can bind |
| RuntimeClass | A node runtime handler matching the RuntimeClass handler | The scheduled Pod cannot start with that RuntimeClass |
| Admission behavior | Reachable TLS webhook Service, trusted CA bundle, namespace-scoped selector | The server or TLS verification is unavailable |

## Reusable controller setup

Install and verify Metrics Server before the HPA suite. Install Contour through
Podman Desktop's Kubernetes resources catalog before the Ingress suite. For
Gateway API, install compatible CRDs, configure the controller, and verify a
programmed Gateway before applying a route fixture. The shared prerequisite
guide contains the exact readiness checks and local-Kind-only controller
configuration.

## Safety and cleanup

Use one disposable `test-*` namespace per workflow. Do not modify system
components or pre-existing workloads. Remove port forwards, test namespaces,
and cluster-scoped fixtures after evidence is captured; retain shared
controllers and CRDs when they are intended for the next workflow.
