# Cluster preparation

Prepare this local Kind environment before using the Kubernetes Dashboard
workflows. It creates three nodes and exposes ports for locally installed
Ingress and Gateway controllers.

## 1. Create the Kind cluster

Keep host ports `9090` and `9443` free, then run the configuration in this
directory:

```sh
kind create cluster --config kind-kubernetes-dashboard-test.yaml
kubectl config use-context kind-kubernetes-dashboard-test
kubectl wait --for=condition=Ready node --all --timeout=120s
kubectl get nodes -o wide
```

The configuration is
[`kind-kubernetes-dashboard-test.yaml`](kind-kubernetes-dashboard-test.yaml).
It creates one control-plane node, two worker nodes, labels the control-plane
node `ingress-ready=true`, and maps local ports `9090` and `9443` to ports 80
and 443 on that node.

In Podman Desktop, select `kind-kubernetes-dashboard-test` as the active
Kubernetes context.

## 2. Add optional cluster components

Use the matching section in the [cluster preparation guide](../../../cluster-test-prerequisites.md)
when the environment needs one of these components:

- Metrics Server
- Contour and its `contour` IngressClass
- Gateway API CRDs and Contour Gateway configuration
