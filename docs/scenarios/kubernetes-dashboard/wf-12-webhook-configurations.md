# WF-12: Webhook Configurations (New in 0.6.0)

This scenario verifies that MutatingWebhookConfigurations and ValidatingWebhookConfigurations are visible in the Dashboard with correct details, and that they can be deleted independently of each other.

## Prerequisites

- Kind cluster running and connected in Podman Desktop.
- Apply the required resources:
  ```bash
  kubectl apply -f pr-tests.yaml
  kubectl apply -f pr-1226-validating-webhook.yaml
  ```
  Resource files:
  - [pr-tests.yaml](resources/pr-tests.yaml) — provides MutatingWebhookConfiguration (`sample-mwc`)
  - [pr-1226-validating-webhook.yaml](resources/pr-1226-validating-webhook.yaml) — provides ValidatingWebhookConfiguration (`sample-vwc`)

## Scenario Steps

### Mutating Webhook

1. **Verify MutatingWebhookConfiguration**  
   Navigate to Mutating Webhook Configs and verify `sample-mwc` shows Webhooks=1, Failure Policy=Ignore.

2. **Open sample-mwc details**  
   Click on `sample-mwc` to open its details page.  
   **Expected:** webhook name=`sample.example.com`, rule: operations=[CREATE], resources=[pods], namespaceSelector matches `default`, clientConfig.url=`https://example.com/mutate`.

### Validating Webhook

3. **Verify ValidatingWebhookConfiguration**  
   Navigate to Validating Webhook Configs and verify `sample-vwc` shows Webhooks=1, Failure Policy=Ignore.

4. **Open sample-vwc details**  
   Click on `sample-vwc` to open its details page.  
   **Expected:** webhook name=`sample.example.com`, clientConfig.url=`https://example.com/validate`.

### Delete — Verify Independence

5. **Delete sample-mwc via Dashboard**  
   Use the delete action on `sample-mwc` on the Mutating Webhook Configs page.  
   **Expected:** `sample-mwc` disappears from Mutating Webhook Configs.

6. **Verify sample-vwc is unaffected**  
   Navigate to Validating Webhook Configs.  
   **Expected:** `sample-vwc` is still present — mutating and validating webhook configurations are independent resources.

7. **Delete sample-vwc via Dashboard**  
   Use the delete action on `sample-vwc`.  
   **Expected:** `sample-vwc` disappears. Both webhook config pages now show an empty state.
