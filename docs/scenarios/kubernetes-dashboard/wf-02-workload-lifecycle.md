# WF-02: Workload Lifecycle

This scenario verifies deploy-scale-heal-delete operations for Deployments, DaemonSets, ReplicaSets, Jobs, and CronJobs via the Kubernetes Dashboard UI.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the dedicated workload fixture:
  ```bash
  kubectl apply -f resources/v06-workloads.yaml
  ```
  Resource file: [v06-workloads.yaml](resources/v06-workloads.yaml)
  Namespace: `qe-v06-workflows`

> **Note:** The fixture does not create Node objects. Kind manages its own nodes; the Nodes page will show the active Kind nodes.

## Scenario Steps

### Deploy & Observe

1. **Navigate to Deployments (namespace: qe-v06-workflows)**
   Open the Dashboard and select the Deployments page with namespace set to `qe-v06-workflows`.
   **Expected:** `qe-v06-web` appears with Pods=1/1 and Conditions showing Available=True.

2. **Open qe-v06-web details**
   Click on `qe-v06-web` to open its details page.
   **Expected:** The pod list shows the single running pod with its name and age. The Conditions table shows both Available and Progressing as True.

### Scale Up via Dashboard (New in 0.6.0)

3. **Scale qe-v06-web to 3 replicas**
   Click the Scale button on `qe-v06-web`, set replicas to 3, and confirm.
   **Expected:** The Pods count in the Deployments row updates to 3. Navigating to the Pods page shows 3 pods for `qe-v06-web` all reaching Running state.

### Pod Self-Healing

4. **Delete one of qe-v06-web's pods via Dashboard**
   On the Pods page, select one of `qe-v06-web`'s pods and use the delete action.
   **Expected:** The Pods page briefly shows 2 pods. Within approximately 30 seconds, `qe-v06-web`'s controller recreates the pod and the count returns to 3.

### Scale Down & Cleanup via Dashboard

5. **Scale qe-v06-web back to 1 replica**
   Use the Scale button on `qe-v06-web` to set replicas to 1.
   **Expected:** 2 pods terminate and disappear from the Pods page. The Deployments row shows 1/1.

6. **Apply a new Deployment via Apply YAML**
   Use the Apply YAML feature to apply a minimal Deployment in `qe-v06-workflows` using the name `test-deployment` (for example, the `nginx:1.25-alpine` image with 1 replica).
   **Expected:** `test-deployment` appears in the Deployments list.

7. **Delete the test deployment via Dashboard**
   Delete `test-deployment` using the Dashboard delete action.
   **Expected:** `test-deployment` disappears. Its pod also disappears from the Pods page.

### Other Workload Types

8. **Navigate to DaemonSets**
   Open the DaemonSets page (namespace: `qe-v06-workflows`).
   **Expected:** `qe-v06-daemon` shows a Ready count equal to the number of schedulable nodes. The Up-to-date column matches.

9. **Navigate to ReplicaSets**
   Open the ReplicaSets page.
   **Expected:** `qe-v06-replicaset` shows Desired=1, Current=1, Ready=1. The Owner column is visible.

10. **Navigate to Jobs**
   Open the Jobs page.
   **Expected:** `qe-v06-job` shows the Completions column and reaches completion.

11. **Navigate to CronJobs**
   Open the CronJobs page.
   **Expected:** `qe-v06-cron` shows Schedule=`*/5 * * * *`. The Last Scheduled column is populated after its first run.

## Cleanup

```bash
kubectl delete -f resources/v06-workloads.yaml --ignore-not-found
```
