# Kubernetes Dashboard cluster preparation

Use this guide to prepare only the cluster capabilities required by the
Dashboard scenarios. The three-node Kind cluster is required for every
workflow. Install Metrics Server, Contour, or Gateway API only for the test
cases that need them.

| Capability | Needed by | Why it is needed |
| --- | --- | --- |
| Three Kind nodes | All sections; DaemonSet and Nodes workflows specifically | Provides a control plane and two workers so node roles, scheduling, and one-Pod-per-node behavior are observable. |
| Metrics Server | HPA live-scaling workflow | Supplies the CPU metrics that HPA reads. Without it, the HPA reports `<unknown>` and cannot be tested. |
| Contour | Ingress workflow | Provides an IngressClass and data plane that can accept HTTP traffic on the Kind-mapped host port. |
| Gateway API and Contour Gateway provisioner | Gateway and HTTPRoute workflow | Adds Gateway API resources and a controller that sets Gateway and HTTPRoute status. |

## 1. Create the multi-node Kind cluster

Run these commands from the directory that contains
[`kind-kubernetes-dashboard-test.yaml`](scenarios/kubernetes-dashboard/setup/kind-kubernetes-dashboard-test.yaml):

```sh
kind create cluster --config kind-kubernetes-dashboard-test.yaml
kubectl config use-context kind-kubernetes-dashboard-test
kubectl wait --for=condition=Ready node --all --timeout=120s
kubectl get nodes -o wide
```

The configuration creates one control-plane node and two worker nodes. It maps
`localhost:9090` to port 80 and `localhost:9443` to port 443 on the
control-plane node, and sets its `ingress-ready=true` label. The mappings are
used only by the Ingress and Gateway traffic checks; they do not create an
Ingress controller by themselves.

In Podman Desktop, select `kind-kubernetes-dashboard-test` as the active
Kubernetes context.

## 2. Install Metrics Server

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deployment metrics-server --type=json \
  --patch='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
```

Metrics Server reads kubelet resource usage for the HPA controller. Kind's
locally generated kubelet certificate is not trusted by the default Metrics
Server configuration, so `--kubelet-insecure-tls` is necessary for this test
cluster only. Do not use it on a shared or production cluster.

## 3. Install Contour

Install Contour with the upstream quick-start manifest:

```sh
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl -n projectcontour rollout status deployment/contour --timeout=180s
```

Contour supplies the IngressClass and Envoy data plane used by the Ingress
traffic workflow. Then run:

```sh
kubectl -n projectcontour get deployment contour
kubectl get ingressclass contour
kubectl -n projectcontour get pods,service
```

If the installed Contour manifest uses an Envoy DaemonSet, Envoy needs a Pod on
the control-plane node because that node owns the Kind port mappings. If the
control-plane `NoSchedule` taint prevents this, apply the local-only toleration:

```sh
kubectl -n projectcontour patch daemonset envoy --type=merge \
  -p '{"spec":{"template":{"spec":{"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}}}}'
kubectl -n projectcontour rollout status daemonset/envoy --timeout=180s
```

## 4. Install Gateway API support

First install the standard Gateway API CRDs. They define the GatewayClass,
Gateway, and HTTPRoute resource types. Then install the Contour Gateway
provisioner, which is the controller that accepts those resources:

```sh
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
kubectl apply -f https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml
kubectl -n projectcontour rollout status deployment/contour-gateway-provisioner --timeout=180s
kubectl api-resources | rg 'gatewayclasses|gateways|httproutes'
```

Save the following as `gateway-api-bootstrap.yaml` and apply it:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: test-routing-gateway-class
spec:
  controllerName: projectcontour.io/gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: test-routing-gateway
  namespace: projectcontour
spec:
  gatewayClassName: test-routing-gateway-class
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All
```

```sh
kubectl apply -f gateway-api-bootstrap.yaml
kubectl -n projectcontour wait --for=condition=Accepted gateway/test-routing-gateway --timeout=180s
kubectl -n projectcontour wait --for=condition=Programmed gateway/test-routing-gateway --timeout=180s
```
