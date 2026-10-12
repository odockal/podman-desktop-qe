# Network workflows

These workflows test network resources as related Kubernetes behavior rather
than isolated list entries. Each uses an isolated `test-*` namespace and a
public Red Hat UBI Python image to make HTTP connectivity observable.

Complete the shared [cluster prerequisites](../../../cluster-test-prerequisites.md)
first. The connected identity must be able to list and get the resource types
used by a workflow. A **Not accessible** page is an environment/RBAC result,
not a passed resource test. Port forwarding needs a free local port.
NetworkPolicy enforcement also requires a CNI that implements policy rules;
record that capability before marking a negative connectivity case as passed.

| Group | Workflow | Result |
| --- | --- | --- |
| Network connectivity | [Network connectivity workflow](service-port-forwarding.md) | Service, generated Endpoints and EndpointSlice, Pod replacement, port forwarding, selector recovery, and NetworkPolicy traffic with a CNI gate |
| Routing APIs | [Ingress and Gateway API lifecycle](ingress-gateway-routing.md) | Ingress, Route, and Gateway API visibility with explicit controller gates |

The Network menu also has standalone pages for **Ingress Classes**, **Gateway
Classes**, **Gateways**, **HTTPRoutes**, and **Port Forwarding**. Port
forwarding is started from the **Summary** tab of a Pod, Service, or Deployment;
the Port Forwarding page tracks active forwards.
