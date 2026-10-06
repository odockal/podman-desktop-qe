# Network workflows

These workflows test network resources as related Kubernetes behavior rather
than isolated list entries. Each uses an isolated `test-*` namespace and a
public Red Hat UBI Python image to make HTTP connectivity observable.

Complete the shared [cluster prerequisites](../../../cluster-test-prerequisites.md)
first. Port forwarding needs a free local port. NetworkPolicy enforcement also
requires a CNI that implements policy rules; record that capability before
marking a negative connectivity case as passed.

| Group | Workflow | Result |
| --- | --- | --- |
| Service connectivity | [Service and port-forwarding lifecycle](service-port-forwarding.md) | Endpoints, HTTP connectivity, broken selector, and recovery |
| Service backends and policy | [Endpoints, EndpointSlices, and NetworkPolicy](service-endpoints-policy.md) | Backend discovery and policy configuration with a CNI gate |
