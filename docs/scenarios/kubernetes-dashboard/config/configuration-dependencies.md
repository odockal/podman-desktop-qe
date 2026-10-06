# ConfigMap and Secret dependency lifecycle

## Goal

Verify that ConfigMaps and Secrets are displayed correctly and that a workload
reacts to missing or invalid configuration, then recovers after restoration.

## Setup

Apply this YAML with `kubectl apply -f -` or paste it into Podman Desktop
**Apply YAML**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: qe-v06-config-verify
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: qe-v06-config
  namespace: qe-v06-config-verify
data:
  APP_MODE: dashboard
---
apiVersion: v1
kind: Secret
metadata:
  name: qe-v06-secret
  namespace: qe-v06-config-verify
type: Opaque
stringData:
  API_TOKEN: qe-v06-token
  RECOVERY_TOKEN: restored
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qe-v06-config-consumer
  namespace: qe-v06-config-verify
spec:
  replicas: 1
  selector:
    matchLabels:
      app: qe-v06-config-consumer
  template:
    metadata:
      labels:
        app: qe-v06-config-consumer
    spec:
      containers:
        - name: consumer
          image: busybox:1.36
          command:
            - sh
            - -ec
            - |
              test "$APP_MODE" = "dashboard"
              test "$API_TOKEN" = "qe-v06-token"
              sleep 3600
          env:
            - name: APP_MODE
              valueFrom:
                configMapKeyRef:
                  name: qe-v06-config
                  key: APP_MODE
            - name: API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: qe-v06-secret
                  key: API_TOKEN
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qe-v06-missing-secret
  namespace: qe-v06-config-verify
spec:
  replicas: 1
  selector:
    matchLabels:
      app: qe-v06-missing-secret
  template:
    metadata:
      labels:
        app: qe-v06-missing-secret
    spec:
      containers:
        - name: consumer
          image: busybox:1.36
          command: ["sh", "-c", "sleep 3600"]
          env:
            - name: RECOVERY_TOKEN
              valueFrom:
                secretKeyRef:
                  name: qe-v06-recovery-secret
                  key: RECOVERY_TOKEN
```
It creates the `qe-v06-config-verify` namespace, `qe-v06-config`,
`qe-v06-secret`, a valid `qe-v06-config-consumer` Deployment, and a
`qe-v06-missing-secret` Deployment that intentionally references a Secret that
does not yet exist.

## Dashboard workflow

1. In Podman Desktop, open **Config → ConfigMaps & Secrets** and select
   `qe-v06-config-verify`.
2. Inspect `qe-v06-config` and `qe-v06-secret`. Verify their keys in
   **Summary**, **Inspect**, and **Patch**.
3. Open **Compute → Deployments** and **Pods**. `qe-v06-config-consumer` must
   be `Running`; the missing-secret workload must not become `Running`.
4. Apply the recovery Secret:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: qe-v06-recovery-secret
     namespace: qe-v06-config-verify
   type: Opaque
   stringData:
     RECOVERY_TOKEN: restored
   ```

5. Refresh **Pods**. The Pod controlled by `qe-v06-missing-secret` must become
   `Running` without recreating the Deployment.

## Invalid configuration and recovery

1. Apply the invalid Secret:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: qe-v06-secret
     namespace: qe-v06-config-verify
   type: Opaque
   stringData:
     API_TOKEN: invalid-token
     RECOVERY_TOKEN: restored
   ```

2. In **Pods**, restart the `qe-v06-config-consumer` Pod from its row action.
   The replacement Pod must fail because its startup command requires
   `API_TOKEN=qe-v06-token`.
3. Restore the valid Secret and restart the failed Pod again:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: qe-v06-secret
     namespace: qe-v06-config-verify
   type: Opaque
   stringData:
     API_TOKEN: qe-v06-token
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
kubectl delete namespace qe-v06-config-verify --ignore-not-found
```
