# ConfigMap and Secret dependency lifecycle

## Goal

Verify that ConfigMaps and Secrets are displayed correctly and that a workload
reacts to missing or invalid configuration, then recovers after restoration.

## What each resource proves

| Resource | Role in the workflow | Observable result |
| --- | --- | --- |
| `test-config` ConfigMap | Supplies the non-secret `APP_MODE` setting. | The consumer only stays running when `APP_MODE=dashboard`. |
| `test-secret` Secret | Supplies `API_TOKEN` at container start. | Replacing it with an invalid value makes a newly created consumer fail its startup check. |
| `test-config-consumer` Deployment | Reads both values as environment variables. | Its Pod demonstrates that the Dashboard shows configuration objects and a real workload dependency. |
| `test-missing-secret` Deployment | References a Secret that does not exist initially. | Its Pod remains Pending/ContainerCreating until the referenced Secret is created. |

## Setup

Apply this YAML with `kubectl apply -f -` or paste it into Podman Desktop
**Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-config-verify
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-config
  namespace: test-config-verify
data:
  APP_MODE: dashboard
---
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
  namespace: test-config-verify
type: Opaque
stringData:
  API_TOKEN: test-token
  RECOVERY_TOKEN: restored
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-config-consumer
  namespace: test-config-verify
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-config-consumer
  template:
    metadata:
      labels:
        app: test-config-consumer
    spec:
      containers:
        - name: consumer
          image: registry.access.redhat.com/ubi9/ubi-minimal:latest
          command:
            - sh
            - -ec
            - |
              test "$APP_MODE" = "dashboard"
              test "$API_TOKEN" = "test-token"
              sleep 3600
          env:
            - name: APP_MODE
              valueFrom:
                configMapKeyRef:
                  name: test-config
                  key: APP_MODE
            - name: API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: test-secret
                  key: API_TOKEN
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-missing-secret
  namespace: test-config-verify
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-missing-secret
  template:
    metadata:
      labels:
        app: test-missing-secret
    spec:
      containers:
        - name: consumer
          image: registry.access.redhat.com/ubi9/ubi-minimal:latest
          command: ["sh", "-c", "sleep 3600"]
          env:
            - name: RECOVERY_TOKEN
              valueFrom:
                secretKeyRef:
                  name: test-recovery-secret
                  key: RECOVERY_TOKEN
```
It creates the `test-config-verify` namespace, `test-config`,
`test-secret`, a valid `test-config-consumer` Deployment, and a
`test-missing-secret` Deployment that intentionally references a Secret that
does not yet exist. Kubernetes can schedule the missing-secret Pod, but its
kubelet cannot create the container environment until the Secret exists.

## Dashboard workflow

1. In Podman Desktop, open **Config → ConfigMaps & Secrets** and select
   `test-config-verify`.
2. Inspect `test-config` and `test-secret`. Verify their keys in
   **Summary**, **Inspect**, and **Patch**.
3. Open **Compute → Deployments** and **Pods**. `test-config-consumer` must
   be `Running`; the missing-secret workload must not become `Running` because
   the referenced Secret is absent.
4. Apply the recovery Secret:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: test-recovery-secret
     namespace: test-config-verify
   type: Opaque
   stringData:
     RECOVERY_TOKEN: restored
   ```

5. Refresh **Pods**. The Pod controlled by `test-missing-secret` must become
   `Running` without recreating the Deployment.

## Invalid configuration and recovery

1. Apply the invalid Secret:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: test-secret
     namespace: test-config-verify
   type: Opaque
   stringData:
     API_TOKEN: invalid-token
     RECOVERY_TOKEN: restored
   ```

2. In **Pods**, restart the `test-config-consumer` Pod from its row action.
   The replacement Pod must fail because its startup command requires
   `API_TOKEN=test-token`. Existing containers do not reread an environment
   variable when a Secret changes, which is why the restart is required.
3. Restore the valid Secret and restart the failed Pod again:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: test-secret
     namespace: test-config-verify
   type: Opaque
   stringData:
     API_TOKEN: test-token
     RECOVERY_TOKEN: restored
   ```
4. Verify the replacement is `Running`, then inspect the Secret to confirm the
   restored key is shown.

## Expected evidence

- Both configuration objects appear in the intended namespace.
- A missing Secret prevents the dependent Pod from starting; adding it recovers
  the existing Deployment.
- An invalid Secret affects only a newly started consumer; restoring the valid
  value returns the consumer to `Running`.

## Cleanup

```sh
kubectl delete namespace test-config-verify --ignore-not-found
```
