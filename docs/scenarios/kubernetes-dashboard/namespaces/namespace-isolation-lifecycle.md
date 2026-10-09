# Namespace isolation lifecycle

## Goal

Verify that a namespace appears on the cluster-wide Namespaces page, scopes
namespaced Dashboard pages, and removes its owned resources when deleted.

## Setup

Apply this YAML with **Apply YAML** or `kubectl apply -f -`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-namespace-lifecycle
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-namespace-config
  namespace: test-namespace-lifecycle
data:
  message: namespace-isolated
---
apiVersion: v1
kind: Pod
metadata:
  name: test-namespace-consumer
  namespace: test-namespace-lifecycle
spec:
  containers:
    - name: consumer
      image: registry.access.redhat.com/ubi9/ubi-minimal:latest
      command: ["/bin/sh", "-ec", "echo $MESSAGE; sleep 3600"]
      env:
        - name: MESSAGE
          valueFrom:
            configMapKeyRef:
              name: test-namespace-config
              key: message
```

## Dashboard workflow

1. Open **Access Control → Namespaces**. Verify
   `test-namespace-lifecycle` is Running.
2. Open the namespace details. Verify **Summary**, **Inspect**, and **Patch**
   are available. Summary must show its name, creation timestamp, and the
   `kubernetes.io/metadata.name` label.
3. Open **Compute → Pods**, use the namespace selector to choose
   `test-namespace-lifecycle`, and verify that only
   `test-namespace-consumer` is listed and Running.
4. Open the Pod details. Verify the namespace, Red Hat UBI image, and
   **Summary**, **Inspect**, **Patch**, **Logs**, and **Terminal** tabs.
5. Open **Logs**. The output must contain `namespace-isolated`, proving the
   Pod consumed the ConfigMap from the selected namespace.

## Isolation check

Switch the Pod namespace selector to a different namespace. The test Pod must
not be listed. Switch back to `test-namespace-lifecycle`; it must return.

## Cascading cleanup

1. From **Access Control → Namespaces**, delete
   `test-namespace-lifecycle` and confirm the action.
2. Verify the namespace disappears from the **Namespaces** list.
3. Open **Dashboard** and verify its active namespace selector refreshes: it
   must no longer show `test-namespace-lifecycle` or offer it as a choice.
4. Return to **Compute → Pods**. The namespace and
   `test-namespace-consumer` must no longer be available.

## Expected evidence

- Namespace details expose metadata and raw manifest tabs.
- Namespace selection isolates the Pod list.
- The ConfigMap-backed Pod log contains `namespace-isolated`.
- Deleting the namespace cascades to the test ConfigMap and Pod.
- Namespace selection refreshes after the namespace is deleted.
