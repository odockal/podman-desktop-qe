# WF-02: Workload Lifecycle

This scenario verifies deploy-scale-heal-delete operations for Deployments, DaemonSets, ReplicaSets, Jobs, and CronJobs via the Kubernetes Dashboard UI.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the cluster resources:
  ```bash
  kubectl apply -f cluster-resources.yaml
  ```
  Resource file: [cluster-resources.yaml](resources/cluster-resources.yaml)

> **Note:** `cluster-resources.yaml` contains Node objects designed for the envtest fixture. On Kind, skip applying Node resources — Kind manages its own node(s). The Nodes page will show your Kind node (e.g., `kind-control-plane`) instead of node1/node2.

## Scenario Steps

### Deploy & Observe

1. **Navigate to Deployments (namespace: default)**  
   Open the Dashboard and select the Deployments page with namespace set to `default`.  
   **Expected:** `deploy1` appears with Pods=1/1 and Conditions showing Available=True.

2. **Open deploy1 details**  
   Click on `deploy1` to open its details page.  
   **Expected:** The pod list shows the single running pod with its name and age. The Conditions table shows both Available and Progressing as True.

### Scale Up via Dashboard (New in 0.6.0)

3. **Scale deploy1 to 3 replicas**  
   Click the Scale button on `deploy1`, set replicas to 3, and confirm.  
   **Expected:** The Pods count in the Deployments row updates to 3. Navigating to the Pods page shows 3 pods for `deploy1` all reaching Running state.

### Pod Self-Healing

4. **Delete one of deploy1's pods via Dashboard**  
   On the Pods page, select one of `deploy1`'s pods and use the delete action.  
   **Expected:** The Pods page briefly shows 2 pods. Within approximately 30 seconds, `deploy1`'s controller recreates the pod and the count returns to 3.

### Scale Down & Cleanup via Dashboard

5. **Scale deploy1 back to 1 replica**  
   Use the Scale button on `deploy1` to set replicas to 1.  
   **Expected:** 2 pods terminate and disappear from the Pods page. The Deployments row shows 1/1.

6. **Apply a new Deployment via Apply YAML**  
   Use the Apply YAML feature to apply a minimal Deployment (e.g., nginx image, 1 replica, name=test-delete-me).  
   **Expected:** The new deployment appears in the Deployments list.

7. **Delete the test deployment via Dashboard**  
   Delete `test-delete-me` using the Dashboard delete action.  
   **Expected:** The deployment disappears. Its pod also disappears from the Pods page.

### Other Workload Types

8. **Navigate to DaemonSets**  
   Open the DaemonSets page (namespace: default).  
   **Expected:** `daemonset1` shows a Ready count equal to the number of schedulable nodes. The Up-to-date column matches.

9. **Navigate to ReplicaSets**  
   Open the ReplicaSets page.  
   **Expected:** `replicaset1` shows Desired=1, Current=1, Ready=1. The Owner column references the owning deployment (if any).

10. **Navigate to Jobs**  
    Open the Jobs page.  
    **Expected:** `job1` shows the Completions column. Status reflects whether the job ran to completion.

11. **Navigate to CronJobs**  
    Open the CronJobs page.  
    **Expected:** `cronjob1` shows Schedule=`00 4 * * *`. The Last Scheduled column is populated if the job has run.
