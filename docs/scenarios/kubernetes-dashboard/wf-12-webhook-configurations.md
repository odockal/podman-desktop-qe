# WF-12: Webhook Configurations (New in 0.6.0)

This workflow verifies the two cluster-scoped webhook configuration pages under **Config**. It tests resource visibility and inspection. It does not claim mutation or rejection because the fixture intentionally has no reachable admission server.

## Prerequisites

- A Kind cluster is connected in Podman Desktop.
- Apply [v06-config-webhooks.yaml](resources/v06-config-webhooks.yaml) through **Apply YAML**.

**Expected Apply YAML result:** two resources are applied: one MutatingWebhookConfiguration and one ValidatingWebhookConfiguration.

## Mutating Webhook Configuration

1. Open **Config → Mutating Webhooks**. This page is cluster-scoped and does not show a namespace selector.
2. Verify `qe-v06-mutating-webhook` is Running with Webhooks `1` and Failure Policy `Ignore`.
3. Open details. Verify Summary, Inspect, and Patch are available.
4. In Inspect, verify webhook name `mutate.qe-v06.example.com`, operation `CREATE`, resource `pods`, namespace selector `default`, and URL `https://example.com/mutate`.

## Validating Webhook Configuration

1. Open **Config → Validating Webhooks**. This page is cluster-scoped and does not show a namespace selector.
2. Verify `qe-v06-validating-webhook` is Running with Webhooks `1` and Failure Policy `Ignore`.
3. Open details. Verify Summary, Inspect, and Patch are available.
4. In Inspect, verify webhook name `validate.qe-v06.example.com`, operation `CREATE`, resource `pods`, namespace selector `default`, and URL `https://example.com/validate`.

## Scope and Limitation

The URLs use `example.com` and the namespace selector limits them to `default`; they are safe configuration fixtures, not functional admission servers. Mutation or rejection can be tested only after deploying a reachable TLS webhook service and updating `clientConfig` with a valid service reference and CA bundle. Without that prerequisite, the reproducible Dashboard test is list, details, Inspect, and Patch availability.

## Admission behavior (proposed; requires a webhook server)

1. Deploy a test TLS webhook Service with a certificate signed by the CA configured in the MutatingWebhookConfiguration or ValidatingWebhookConfiguration.
2. Patch the selected configuration so `clientConfig.service`, `caBundle`, rules, and namespace selector point to that test server. Keep the scope limited to a dedicated test namespace.
3. Apply a uniquely named test Pod in that namespace through **Apply YAML**.
4. For the mutating webhook, verify the Pod Inspect output contains the expected injected label, annotation, or environment variable.
5. For the validating webhook, apply a deliberately invalid Pod and verify Apply YAML rejects it; then apply a valid Pod and verify it becomes Running.

**Expected:** the Dashboard shows the resulting admitted or rejected workload state. Do not mark this case passed with the supplied `example.com` fixtures: they intentionally use `failurePolicy: Ignore` and do not contact an admission server.

## Cleanup

```sh
kubectl delete -f resources/v06-config-webhooks.yaml --ignore-not-found
```
