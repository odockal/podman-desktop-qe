# WF-02: Workload Lifecycle

This scenario verifies apply-observe-inspect-update-reconcile-delete operations for Deployments, Deployment-owned ReplicaSets, DaemonSets, Jobs, CronJobs, and StatefulSets via the Kubernetes Dashboard UI.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the dedicated workload fixture from the Dashboard **Apply YAML** page:
  ```bash
  kubectl apply -f resources/v06-workloads.yaml
  ```
  Resource file: [v06-workloads.yaml](resources/v06-workloads.yaml)
  The fixture creates namespace `qe-v06-workflows`. Select that namespace in the Dashboard after applying it.
- Apply the StatefulSet fixture:
  ```bash
  kubectl apply -f resources/v06-statefulsets.yaml
  ```
  Resource file: [v06-statefulsets.yaml](resources/v06-statefulsets.yaml)

> **Note:** The fixture does not create Node objects. Kind manages its own nodes; the Nodes page will show the active Kind nodes.

## Scenario Steps

### Deployment lifecycle

1. **Apply and observe the Deployment**
   Open **Compute → Apply YAML**, apply `v06-workloads.yaml`, then select namespace `qe-v06-workflows` and open **Deployments**.
   **Expected:** `qe-v06-web` appears with Pods=1/1 and Conditions showing Available=True.

2. **Inspect qe-v06-web**
   Click on `qe-v06-web` to open its details page.
   **Expected:** The Summary tab shows the single running pod and Available/Progressing conditions. The Inspect and Patch tabs are available.

### Scale Up via Dashboard (New in 0.6.0)

3. **Scale qe-v06-web to 3 replicas**
   Click the Scale button on `qe-v06-web`, set replicas to 3, and confirm.
   **Expected:** The Pods count in the Deployments row updates to 3. Navigating to the Pods page shows 3 pods for `qe-v06-web` all reaching Running state.

### Pod Self-Healing

4. **Reconcile after deleting an owned Pod**
   Open **Pods**, select one of `qe-v06-web`'s pods, click **Delete Pod**, and confirm **Yes**.
   **Expected:** The deleted pod disappears and a new pod appears. Within approximately 30 seconds, the Deployment returns to 3 ready pods.

### Scale Down & Cleanup via Dashboard

5. **Scale qe-v06-web back to 1 replica**
   Use the Scale button on `qe-v06-web` to set replicas to 1.
   **Expected:** 2 pods terminate and disappear from the Pods page. The Deployments row shows 1/1.

6. **Apply a temporary Deployment via Apply YAML**
   Use the Apply YAML feature to apply a minimal Deployment in `qe-v06-workflows` using the name `test-deployment` (for example, the `nginx:1.25-alpine` image with 1 replica).
   **Expected:** `test-deployment` appears in the Deployments list.

7. **Delete the test deployment via Dashboard**
   Delete `test-deployment` using the Dashboard delete action.
   **Expected:** `test-deployment` disappears. Its pod also disappears from the Pods page.

### DaemonSet lifecycle

8. **Observe and inspect the DaemonSet**
   Open the DaemonSets page (namespace: `qe-v06-workflows`).
   Open `qe-v06-daemon` and check Summary, Inspect, and Patch.
   **Expected:** `qe-v06-daemon` shows a Ready count equal to the number of schedulable nodes. The Up-to-date column matches.

9. **Reconcile an owned DaemonSet Pod**
   Open **Pods**, select a pod controlled by `qe-v06-daemon`, and delete it.
   **Expected:** A replacement pod is scheduled on the same eligible node and the DaemonSet returns to its expected Ready count.

10. **Delete the DaemonSet**
    Return to **DaemonSets**, select `qe-v06-daemon`, click **Delete**, and confirm **Yes**.
    **Expected:** The DaemonSet and its owned pods disappear.

### Deployment-owned ReplicaSet lifecycle

11. **Observe the Deployment-owned ReplicaSet**
    Open **ReplicaSets** and locate the ReplicaSet whose Owner column is `qe-v06-web`.
    **Expected:** Desired, Current, and Ready are 1 after scaling the Deployment back to 1. The generated ReplicaSet name may contain a hash and must not be hard-coded.

12. **Inspect the owned ReplicaSet**
    Open the ReplicaSet and check Summary, Inspect, and Patch.
    **Expected:** The details page identifies the namespace and shows `qe-v06-web` as the owner.

13. **Reconcile the owned ReplicaSet**
    Delete the ReplicaSet owned by `qe-v06-web` and confirm **Yes**.
    **Expected:** The Deployment creates a replacement ReplicaSet, and the new ReplicaSet returns to Desired=1, Current=1, Ready=1.

14. **Delete the temporary Deployment**
    Return to **Deployments**, delete `test-deployment`, and confirm **Yes** if it is still present.
    **Expected:** The temporary Deployment and its pod disappear.

### Job lifecycle

15. **Observe and inspect the Job**
   Open the Jobs page.
   **Expected:** `qe-v06-job` remains visible after completion, shows `1/1` completions, and exposes Summary, Inspect, and Patch.

16. **Delete the completed Job**
    Select `qe-v06-job`, click **Delete**, and confirm **Yes**.
    **Expected:** `qe-v06-job` disappears from the Jobs page.

### CronJob lifecycle

17. **Observe the CronJob**
   Open the CronJobs page.
   **Expected:** `qe-v06-cron` shows Schedule=`* * * * *` (Every minute). The Last Scheduled column is populated within one minute.

18. **Inspect and suspend the CronJob**
    Open `qe-v06-cron`, verify Summary, Inspect, and Patch, then use the Patch tab to change `suspend: false` to `suspend: true` and click **Patch resource**.
    **Expected:** Summary shows Suspend=True and no new Job is created while suspended.

19. **Resume and delete the CronJob**
    Change `suspend: true` back to `suspend: false`, click **Patch resource**, then delete the CronJob from its details page.
    **Expected:** Summary shows Suspend=False before deletion. After confirmation, `qe-v06-cron` disappears from the CronJobs page.

### StatefulSet

20. **Observe and inspect the StatefulSet**
    Open the StatefulSets page.
    **Expected:** `qe-v06-stateful` shows 2 desired/current/ready replicas and uses Service=`qe-v06-stateful`.

21. **Verify stable StatefulSet Pod names**
    Open the Pods page.
    **Expected:** Pods `qe-v06-stateful-0` and `qe-v06-stateful-1` are Running.

22. **Delete one StatefulSet Pod**
    Delete `qe-v06-stateful-0` from the Pods page.
   **Expected:** The StatefulSet recreates `qe-v06-stateful-0` with the same ordinal and returns to 2/2 ready replicas.

## Cleanup

```bash
kubectl delete -f resources/v06-workloads.yaml --ignore-not-found
kubectl delete -f resources/v06-statefulsets.yaml --ignore-not-found
```
