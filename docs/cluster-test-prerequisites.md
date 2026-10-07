# Kubernetes Dashboard cluster preparation

Use these commands to create a reusable local Kind cluster and install the
optional components used by the Dashboard environment.

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
control-plane node, and sets its `ingress-ready=true` label.

In Podman Desktop, select `kind-kubernetes-dashboard-test` as the active
Kubernetes context.

## 2. Install Metrics Server

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.9.0/components.yaml
kubectl -n kube-system patch deployment metrics-server --type=json \
  --patch='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
```

`--kubelet-insecure-tls` is for this local Kind cluster only.

## 3. Install Contour

Install **Contour** from the Podman Desktop Kubernetes resources catalog, then
run:

```sh
kubectl -n projectcontour get deployment contour
kubectl -n projectcontour get daemonset envoy
kubectl get ingressclass contour
kubectl -n projectcontour rollout status deployment/contour --timeout=180s
kubectl -n projectcontour rollout status daemonset/envoy --timeout=180s
```

Envoy needs a pod on the control-plane node because that node owns the Kind
port mappings. If the control-plane `NoSchedule` taint prevents this, apply the
local-only toleration:

```sh
kubectl -n projectcontour patch daemonset envoy --type=merge \
  -p '{"spec":{"template":{"spec":{"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}}}}'
kubectl -n projectcontour rollout status daemonset/envoy --timeout=180s
```

## 4. Install Gateway API support

Install Gateway API CRDs compatible with the Contour release. For Contour
1.32:

```sh
kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/release-1.32/examples/gateway/00-crds.yaml
kubectl api-resources | rg 'gatewayclasses|gateways|httproutes'
```

Edit the `projectcontour/contour` ConfigMap and add this to its `contour.yaml`
value, preserving its existing settings:

```yaml
gateway:
  gatewayRef:
    namespace: projectcontour
    name: test-routing-gateway
```

Restart Contour:

```sh
kubectl -n projectcontour rollout restart deployment/contour
kubectl -n projectcontour rollout status deployment/contour --timeout=180s
```

Save the following as `gateway-api-bootstrap.yaml` and apply it:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: test-routing-gateway
spec:
  controllerName: projectcontour.io/gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: test-routing-gateway
  namespace: projectcontour
spec:
  gatewayClassName: test-routing-gateway
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
