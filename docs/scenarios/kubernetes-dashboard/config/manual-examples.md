# Manual Config Workflows in Podman Desktop

> The workflow-based Config suite is now the source of truth. Start with
> [Config section workflows](README.md)
> for fixed `test-*` resource definitions, prerequisites, expected results,
> and cleanup. This consolidated runbook remains as a general manual example.

This runbook reproduces the Config-section workflows using only the Kubernetes Dashboard extension in Podman Desktop. No `kubectl` commands are required.

## Prerequisites

- A running Kubernetes cluster connected in Podman Desktop.
- The Kubernetes Dashboard extension open.
- An isolated namespace named `qe-config-manual`.
- Use **Config → Apply YAML → Custom YAML** for every fixture below.

The examples use public Red Hat UBI images so they run without registry
credentials on the local Kind test cluster.

## 1. Create the test namespace

Open **Config → ConfigMaps & Secrets → Apply YAML → Custom YAML**, paste the following, and select **Apply**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: qe-config-manual
```

Switch the namespace selector to `qe-config-manual` after the namespace appears.

## 2. ConfigMap and Secret consumed by a workload

Apply this YAML from any resource page:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: qe-config
data:
  APP_MODE: functional
  MESSAGE: from-configmap
  config.txt: initial-config
---
apiVersion: v1
kind: Secret
metadata:
  name: qe-secret
type: Opaque
stringData:
  USERNAME: qe-user
  PASSWORD: qe-password
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qe-config-consumer
  labels:
    app: qe-config-consumer
spec:
  replicas: 2
  selector:
    matchLabels:
      app: qe-config-consumer
  template:
    metadata:
      labels:
        app: qe-config-consumer
    spec:
      containers:
      - name: nginx
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        env:
        - name: APP_MODE
          valueFrom:
            configMapKeyRef:
              name: qe-config
              key: APP_MODE
        - name: QE_USERNAME
          valueFrom:
            secretKeyRef:
              name: qe-secret
              key: USERNAME
        volumeMounts:
        - name: config-volume
          mountPath: /etc/qe-config
      volumes:
      - name: config-volume
        configMap:
          name: qe-config
```

Verify:

1. **ConfigMaps & Secrets** lists `qe-config` and `qe-secret` as Running.
2. Open each resource and check **Summary**, **Inspect**, and **Patch** tabs.
3. Open **Compute → Deployments** and confirm `qe-config-consumer` is Running with 2/2 Pods.
4. Open **Compute → Pods** and confirm both Pods are Running.

### Missing Secret recovery

Apply this Deployment before creating `qe-missing-secret`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qe-config-missing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: qe-config-missing
  template:
    metadata:
      labels:
        app: qe-config-missing
    spec:
      containers:
      - name: nginx
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        env:
        - name: REQUIRED_PASSWORD
          valueFrom:
            secretKeyRef:
              name: qe-missing-secret
              key: PASSWORD
```

Open **Pods** and verify the Pod shows a configuration error. Then apply:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: qe-missing-secret
type: Opaque
stringData:
  PASSWORD: recovered
```

Return to **Pods** and verify the Pod becomes Running.

## 3. Quota and default container resources

Apply:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: qe-quota
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    limits.cpu: "4"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: qe-limits
spec:
  limits:
  - type: Container
    default:
      cpu: 200m
    defaultRequest:
      cpu: 100m
```

Verify in **Config**:

- **Resource Quotas** shows `qe-quota` and its usage.
- **Limit Ranges** shows `qe-limits`.

Apply a Pod without resources. Open its details and verify the default request and limit were added. Then apply a Pod requesting more CPU than the quota permits; Apply YAML should fail and the Pod should not appear as Running.

## 4. HPA and Pod Disruption Budget

Apply:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: qe-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: qe-config-consumer
  minReplicas: 2
  maxReplicas: 4
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: qe-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: qe-config-consumer
```

Verify:

- **Horizontal Pod Autoscalers** shows target Deployment, min/max replicas, current replicas, and desired replicas.
- **Pod Disruption Budgets** shows current healthy, desired healthy, expected Pods, and allowed disruptions.

Prerequisite: install metrics-server and confirm `kubectl top nodes` returns data before starting this HPA workflow. Do not treat an HPA with `unknown` metrics as an executed scaling test.

For a repeatable scale-up check, use the YAML in
[Live HPA scaling](hpa-live-scaling.md).
In the **Horizontal Pod Autoscalers** page, select `test-hpa-verify` and
verify `test-hpa-live` reports a numeric CPU value above `60%` and reaches
three current and desired replicas.

## 5. ServiceAccount, Role, and RoleBinding

Apply:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: qe-reader
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: qe-reader
rules:
- apiGroups: [""]
  resources: ["pods", "configmaps"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: qe-reader
subjects:
- kind: ServiceAccount
  name: qe-reader
roleRef:
  kind: Role
  name: qe-reader
  apiGroup: rbac.authorization.k8s.io
```

Open **Access Control → Service Accounts**, **Roles**, and **Role Bindings**. Confirm the names, namespace, Role rules, and ServiceAccount subject are shown. A true allow/deny API authorization check requires a workload that calls the Kubernetes API or a separate CLI check.

## 6. Lease, PriorityClass, and RuntimeClass

Apply:

```yaml
apiVersion: coordination.k8s.io/v1
kind: Lease
metadata:
  name: qe-lease
spec:
  holderIdentity: qe-test-a
  leaseDurationSeconds: 30
  leaseTransitions: 1
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: qe-high-priority
value: 100000
globalDefault: false
description: QE functional priority
---
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: qe-runc
handler: runc
```

Verify **Leases**, **Priority Classes**, and **Runtime Classes** show holder, duration, value, default flag, and handler. Use a Pod with `priorityClassName: qe-high-priority` and `runtimeClassName: qe-runc` to confirm the values in the Pod’s Kube/Inspect view. Runtime handlers are cluster-dependent.

## 7. Webhook configuration pages

Webhook mutation/rejection cannot be functionally demonstrated with YAML alone; it needs a reachable webhook server. With a test server available, apply the corresponding MutatingWebhookConfiguration or ValidatingWebhookConfiguration, then create a matching Pod and verify mutation or rejection.

Without a server, use **Mutating Webhooks** and **Validating Webhooks** to verify the configuration name, webhook count, rules, and failure policy only.

## Cleanup

From **Namespaces**, open `qe-config-manual` and delete it after the run. Confirm the namespace and its namespaced resources disappear. Delete the cluster-scoped `qe-high-priority`, `qe-runc`, and any webhook configurations separately from their resource pages.

## Results from the direct Podman Desktop run

The workflows were exercised against the local `kind-kubernetes-dashboard-test` cluster using an isolated `qe-config-flow` namespace. The temporary fixtures were removed after verification.

- ConfigMap and Secret consumers reached Running, and their Summary, Inspect, and Patch pages opened.
- A Deployment referencing a missing Secret entered `CreateContainerConfigError`; adding the Secret recovered the Pod to Running.
- Patching the ConfigMap and restarting the consumer exposed the new mounted value.
- ResourceQuota rejected a Pod that exceeded the CPU quota.
- LimitRange added the expected `100m` request and `200m` limit to a Pod without resources.
- The PDB page showed current healthy, desired healthy, expected Pods, and allowed disruptions.
- ServiceAccount, Role, and RoleBinding pages showed the expected namespace and binding relationship. Cluster authorization checks confirmed the reader could list Pods but could not delete them.
- Lease, PriorityClass, and RuntimeClass resources appeared with their expected values; the PriorityClass/RuntimeClass workload ran successfully.
- HPA live scaling requires metrics-server and a successful `kubectl top nodes` check before execution.
- Mutating and Validating Webhook pages displayed the configurations. Mutation/rejection was not run because that requires a reachable webhook server.
- Secret data was displayed as base64-encoded values in the details view; this is a UX/security observation for follow-up.
