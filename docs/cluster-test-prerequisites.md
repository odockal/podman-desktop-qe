# Kubernetes Dashboard test-cluster prerequisites

Use this configuration before executing the Kubernetes Dashboard functional
workflows. It separates baseline coverage from workflows that require an
additional cluster capability.

## 1. Baseline multi-node Kind cluster

Create the canonical three-node cluster. Save the
[Kind configuration from the setup section](scenarios/kubernetes-dashboard/setup/README.md#kind-configuration)
as `kind-daemonset-cluster.yaml` before running these commands:

```sh
kind create cluster --config kind-daemonset-cluster.yaml
kubectl config use-context kind-daemonset-test
kubectl wait --for=condition=Ready node --all --timeout=120s
kubectl get nodes -o wide
```

The Nodes page must show one control-plane node and two worker nodes as
`Ready`. Do not use a single-node cluster for controller, scheduling,
DaemonSet, or node-placement workflows.

The profile maps `localhost:9090` to port 80 and `localhost:9443` to port 443
on the Kind control-plane node. These mappings are required for the external
Ingress and Gateway API checks below. The `ingress-ready=true` node label is
included so that an ingress controller can explicitly target that node.

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
scaling. Its workload should report CPU above its target and reach the expected
current and desired replica counts.

## 3. Contour Ingress prerequisite

The Ingress workflow is an end-to-end test only when an ingress controller is
running and can receive the Kind port-mapped request. In Podman Desktop,
install **Contour** from the Kubernetes resources catalog, then select the
same cluster context used by `kubectl`.

Verify the controller and its standard class before applying an Ingress
fixture:

```sh
kubectl -n projectcontour get deployment contour
kubectl -n projectcontour get daemonset envoy
kubectl get ingressclass contour
kubectl -n projectcontour rollout status deployment/contour --timeout=180s
kubectl -n projectcontour rollout status daemonset/envoy --timeout=180s
```

On this multi-node Kind profile, Envoy must run on the control-plane node: it
is the node that owns the `9090` and `9443` host-port mappings. If Envoy does
not have a ready pod on that node because of its `NoSchedule` taint, add the
following local-test-only toleration and wait for the DaemonSet rollout:

```sh
kubectl -n projectcontour patch daemonset envoy --type=merge \
  -p '{"spec":{"template":{"spec":{"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Exists","effect":"NoSchedule"}]}}}}'
kubectl -n projectcontour rollout status daemonset/envoy --timeout=180s
```

Use `ingressClassName: contour` in the Ingress fixture. A newly created
IngressClass can appear as healthy in the Dashboard but will not route traffic
unless its controller value is managed by the installed controller.

After applying the workload, Service, and Ingress, verify actual routing—not
only object visibility:

```sh
curl --fail --resolve <host>:9090:127.0.0.1 http://<host>:9090/
```

Replace `<host>` with the Ingress rule host. A successful request must return
the backend response. A deliberately broken Service selector must yield a
failure (normally HTTP 503), and restoring the selector must restore a 2xx
response.

## 4. Gateway API prerequisite

Gateway API requires both its CRDs and a controller. Contour provides the
controller, but it must be configured to manage a Gateway reference. Install
the Gateway API CRDs that match the Contour release installed by Podman
Desktop. For Contour 1.32, use:

```sh
kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour/release-1.32/examples/gateway/00-crds.yaml
kubectl api-resources | rg 'gatewayclasses|gateways|httproutes'
```

Configure Contour with a Gateway reference. The `gatewayRef` form is required
by the Contour version used for this profile; do not use obsolete `namespace`
and `name` fields directly under `gateway`.

Edit the `contour` ConfigMap in the `projectcontour` namespace and add the
following section to its `contour.yaml` value. Preserve the existing settings.

```yaml
# Add to the projectcontour/contour ConfigMap configuration.
gateway:
  gatewayRef:
    namespace: projectcontour
    name: test-routing-gateway
```

Apply the ConfigMap change and restart Contour:

```sh
kubectl -n projectcontour rollout restart deployment/contour
kubectl -n projectcontour rollout status deployment/contour --timeout=180s
```

Create the controller-owned GatewayClass and its Gateway before creating an
HTTPRoute. These are cluster setup resources, not a substitute for the
namespaced test fixture. Save this inline manifest as
`gateway-api-bootstrap.yaml` in the working directory:

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

After applying the YAML, the Gateway must report `Accepted=True` and
`Programmed=True` before an HTTPRoute test begins:

```sh
kubectl apply -f gateway-api-bootstrap.yaml
kubectl -n projectcontour wait --for=condition=Accepted gateway/test-routing-gateway --timeout=180s
kubectl -n projectcontour wait --for=condition=Programmed gateway/test-routing-gateway --timeout=180s
```

The HTTPRoute test must verify `Accepted=True`, `ResolvedRefs=True`, and a real
request through the mapped Envoy port, for example:

```sh
curl --fail -H 'Host: gateway.test' http://127.0.0.1:9090/
```

Delete the HTTPRoute before deleting the Gateway or GatewayClass. Its route
must stop serving after cleanup. Retain the CRDs, Contour configuration,
Contour controller, and standard `contour` IngressClass as reusable cluster
prerequisites for the next run.

## 5. Capability gates by workflow

| Workflow area | Required cluster configuration | Do not run when |
| --- | --- | --- |
| Dashboard, Nodes, Pods, Deployments, ReplicaSets, Jobs, CronJobs, DaemonSets | Three Ready Kind nodes and an active matching context | Nodes are missing, NotReady, or a different context is selected |
| ConfigMap, Secret, ServiceAccount, Role, RoleBinding, ResourceQuota, LimitRange, Lease, PDB | Baseline cluster and permission to create fixtures in an isolated namespace | The active context cannot create the required namespaced resources |
| HPA | Metrics Server and successful `kubectl top nodes` | Metrics are unavailable or reported as `<unknown>` |
| Service and port-forward | Baseline cluster; a local free port for the forwarding check | Service has no endpoints or the selected local port is occupied |
| Ingress | Ready Contour/Envoy, `contour` IngressClass, Envoy scheduled on the mapped control-plane node, and `curl` succeeds through `localhost:9090` | Controller/class is absent, the mapped Envoy pod is not ready, or routing fails |
| Gateway API | Gateway API CRDs, Contour Gateway configuration, and a Gateway reporting `Accepted=True` and `Programmed=True` | CRDs/controller/configuration is absent or the Gateway is not accepted/programmed |
| PVC and dynamic storage | A default or explicitly named `StorageClass` with a working provisioner | PVC remains Pending |
| Static PV lifecycle | A pre-created PV matching the fixture's storage class, mode, and capacity | No matching PV is Available |
| RuntimeClass workload | A node runtime handler that matches the RuntimeClass handler | The node runtime does not advertise the handler |
| Admission webhook behavior | Reachable TLS webhook Service, CA bundle, and a selector limited to the dedicated test namespace | The Service is unreachable, TLS fails, the selector is omitted, or the fixture uses a placeholder URL |

## 6. Test namespace and cleanup policy

Use one unique namespace per workflow run, such as `test-hpa-workflow`.
Do not alter system components or pre-existing workloads when testing resource
behavior. Cluster-scoped fixtures, port forwards, and webhook configurations
need explicit cleanup steps; namespaced fixtures can be removed by deleting
only their dedicated namespace after evidence has been captured.

## 7. CI gates

CI should create the multi-node Kind cluster, install Metrics Server before
the HPA suite, install and verify Contour before the Ingress suite, and verify
the Gateway API CRDs plus a programmed Gateway before the Gateway API suite.
Poll readiness conditions rather than relying on fixed delays. Run
prerequisite-dependent suites only after their gate succeeds; mark a missing
capability as an environment setup failure, not an extension result.
