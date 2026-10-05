# WF-11: Configuration & Policies (New in 0.6.0)

This scenario verifies that configuration and policy resources — LimitRanges, ResourceQuotas, HPAs, PodDisruptionBudgets, PriorityClasses, RuntimeClasses, and Leases — are visible in the Dashboard and can be deleted.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the required resources:
  ```bash
  kubectl apply -f resources/pr-tests.yaml
  kubectl apply -f resources/access-control.yaml
  ```
  Resource files:
  - [pr-tests.yaml](resources/pr-tests.yaml) — provides LimitRange, HPA, PDB, PriorityClass, RuntimeClass, Lease, MutatingWebhookConfig, and a `web` Deployment (nginx, 2 replicas)
  - [access-control.yaml](resources/access-control.yaml) — provides ResourceQuota `test-quota`

`pr-tests.yaml` includes a `web` Deployment (nginx, 2 replicas) that the HPA and PDB target.

## Scenario Steps

### Quota & Limits

1. **Verify ResourceQuota**  
   Navigate to Resource Quotas and verify `test-quota` shows a Request Count column with constraints. Open the details page.  
   **Expected:** Hard limits: pods=10, requests.cpu=2, limits.cpu=4.

2. **Verify LimitRange**  
   Navigate to Limit Ranges and verify `mem-limit` appears with Type=Container, Count=1. Open the details page.  
   **Expected:** Container default=cpu:200m, defaultRequest=cpu:100m.

### HPA Observing Live Scaling

3. **Verify HPA**  
   Navigate to Horizontal Pod Autoscalers and verify `web-hpa` shows Min Pods=1, Max Pods=5, Metrics=`cpu/80%`, targeting the `web` Deployment.

4. **Verify web deployment replica count**  
   Navigate to Deployments and verify the `web` deployment's replica count reflects HPA decisions (initially 2 since `pr-tests.yaml` sets replicas=2).

### PDB

5. **Verify PodDisruptionBudget**  
   Navigate to Pod Disruption Budgets and verify `web-pdb` shows Min Available=1 and a populated Current Healthy column. Open the details page.  
   **Expected:** minAvailable=1, selector app=web.

### Other Resources

6. **Verify PriorityClass**  
   Navigate to Priority Classes and verify `high-priority` shows Value=1000000, Global Default=false, Preemption Policy=PreemptLowerPriority.

7. **Verify RuntimeClass**  
   Navigate to Runtime Classes and verify `sample-runc` shows Handler=runc.

8. **Verify Lease**  
   Navigate to Leases and verify `sample-lease` shows Holder=`reviewer`, Lease Duration=30s, and a populated Renew Time.

### Delete via Dashboard

9. **Delete mem-limit via Dashboard**  
   Use the delete action on `mem-limit` on the Limit Ranges page.  
   **Expected:** `mem-limit` disappears from Limit Ranges. `test-quota` is still present in Resource Quotas.

10. **Delete test-quota via Dashboard**  
    Use the delete action on `test-quota` on the Resource Quotas page.  
    **Expected:** `test-quota` disappears from Resource Quotas.
