# Admission webhook lifecycle

## Goal

Verify that the dashboard presents live mutating and validating webhook
configuration, and that Kubernetes invokes a TLS-backed service to mutate a
valid Pod and reject an invalid Pod.

## What the webhooks do

Admission webhooks run after the Kubernetes API receives an object but before
it stores that object. This workflow uses the same TLS-backed Service for two
different decisions:

| Configuration | Purpose | Expected effect |
| --- | --- | --- |
| `test-mutating-webhook` | Changes an accepted Pod before it is persisted. | Adds `test-mutated: "true"` to every Pod created in the target namespace. |
| `test-validating-webhook` | Accepts or rejects the final object. | Allows only Pods labelled `test-valid: "true"`; rejects the other test Pod. |

The `namespaceSelector` limits both hooks to `test-webhook-target`. The
control namespace is deliberately excluded so the webhook server remains
available. `failurePolicy: Fail` makes an unavailable webhook fail closed,
which is why the workflow must be run only in these disposable namespaces.

## Prerequisites

- A working multi-node Kind context with permission to create cluster-scoped
  webhook configurations.
- `openssl` and `kubectl` available locally.
- Do not run this workflow against a shared or production cluster. It installs
  `failurePolicy: Fail` webhooks, scoped only to the dedicated target namespace.

The control namespace deliberately does **not** have the selector label. This
keeps the webhook server able to start even while the test target is subject to
admission.

## Create the webhook service

Create a one-day self-signed certificate whose subject alternative names match
the Service DNS names, then create the TLS Secret. Do not commit the generated
key or certificate.

```sh
openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
  -keyout test-admission.key -out test-admission.crt \
  -subj '/CN=test-admission.test-webhook-control.svc' \
  -addext 'subjectAltName=DNS:test-admission.test-webhook-control.svc,DNS:test-admission.test-webhook-control.svc.cluster.local'

kubectl create namespace test-webhook-control
kubectl -n test-webhook-control create secret tls test-admission-tls \
  --cert=test-admission.crt --key=test-admission.key
kubectl create namespace test-webhook-target
kubectl label namespace test-webhook-target test-webhook-test=true
```
Apply the following server, Deployment, and Service. The server mutates each
accepted Pod with `test-mutated: "true"` and only accepts Pods labeled
`test-valid: "true"`.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-admission-server
  namespace: test-webhook-control
data:
  server.py: |
    import json
    import ssl
    from http.server import BaseHTTPRequestHandler, HTTPServer
    from urllib.parse import urlparse

    class AdmissionHandler(BaseHTTPRequestHandler):
        def respond(self, review, allowed, patch=None, message=None):
            response = {"uid": review["request"]["uid"], "allowed": allowed}
            if patch:
                response["patchType"] = "JSONPatch"
                response["patch"] = patch
            if message:
                response["status"] = {"message": message}
            body = json.dumps({"apiVersion": "admission.k8s.io/v1", "kind": "AdmissionReview", "response": response}).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_POST(self):
            review = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
            path = urlparse(self.path).path
            labels = review["request"]["object"].get("metadata", {}).get("labels", {})
            if path == "/mutate":
                patch = json.dumps([{"op": "add", "path": "/metadata/labels/test-mutated", "value": "true"}])
                self.respond(review, True, patch=patch)
            elif path == "/validate":
                self.respond(review, labels.get("test-valid") == "true", message="test-valid=true is required")
            else:
                self.respond(review, False, message="unknown endpoint")

    server = HTTPServer(("", 8443), AdmissionHandler)
    server.socket = ssl.wrap_socket(server.socket, certfile="/tls/tls.crt", keyfile="/tls/tls.key", server_side=True)
    server.serve_forever()
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-admission
  namespace: test-webhook-control
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-admission
  template:
    metadata:
      labels:
        app: test-admission
    spec:
      containers:
        - name: server
          image: registry.access.redhat.com/ubi9/python-312:latest
          command: ["python", "/app/server.py"]
          ports:
            - containerPort: 8443
          volumeMounts:
            - name: app
              mountPath: /app
            - name: tls
              mountPath: /tls
              readOnly: true
      volumes:
        - name: app
          configMap:
            name: test-admission-server
        - name: tls
          secret:
            secretName: test-admission-tls
---
apiVersion: v1
kind: Service
metadata:
  name: test-admission
  namespace: test-webhook-control
spec:
  selector:
    app: test-admission
  ports:
    - port: 443
      targetPort: 8443
```

Wait for it to become available, then capture the CA bundle used in the next
definition:

```sh
kubectl apply -f webhook-service.yaml
kubectl -n test-webhook-control rollout status deployment/test-admission --timeout=180s
TEST_CA_BUNDLE="$(base64 < test-admission.crt | tr -d '\n')"
```

## Create the scoped webhook configurations

Replace `REPLACE_WITH_CA_BUNDLE` with `TEST_CA_BUNDLE` before applying the
following YAML. The `namespaceSelector` is mandatory: it confines both
webhooks to `test-webhook-target`.

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: test-mutating-webhook
webhooks:
  - name: mutate.test.example
    admissionReviewVersions: ["v1"]
    sideEffects: None
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        test-webhook-test: "true"
    clientConfig:
      service:
        namespace: test-webhook-control
        name: test-admission
        path: /mutate
      caBundle: REPLACE_WITH_CA_BUNDLE
    rules:
      - operations: ["CREATE"]
        apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: test-validating-webhook
webhooks:
  - name: validate.test.example
    admissionReviewVersions: ["v1"]
    sideEffects: None
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        test-webhook-test: "true"
    clientConfig:
      service:
        namespace: test-webhook-control
        name: test-admission
        path: /validate
      caBundle: REPLACE_WITH_CA_BUNDLE
    rules:
      - operations: ["CREATE"]
        apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
```

## Dashboard workflow and expected result

1. Open **Config → Mutating Webhooks** and **Validating Webhooks**. Inspect
   the `test-*` entries: Service target, CA bundle, endpoint, Pod `CREATE`
   rule, selector, and `failurePolicy: Fail` must be visible.
2. In **Apply YAML**, create this valid Pod:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-webhook-valid
     namespace: test-webhook-target
     labels:
       test-valid: "true"
   spec:
     containers:
       - name: sleeper
         image: registry.access.redhat.com/ubi9/ubi-minimal:latest
         command: ["sh", "-c", "sleep 3600"]
   ```

3. Switch **Compute → Pods** to `test-webhook-target`. The Pod must be
   Running. Its **Inspect** output must include `test-mutated: "true"`.
4. In **Apply YAML**, create this invalid Pod:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-webhook-invalid
     namespace: test-webhook-target
     labels:
       test-case: invalid
   spec:
     containers:
       - name: sleeper
         image: registry.access.redhat.com/ubi9/ubi-minimal:latest
         command: ["sh", "-c", "sleep 3600"]
   ```

5. Apply YAML must report `test-valid=true is required`; the invalid Pod
   must not appear in the target namespace. Reapply the valid Pod under a new
   name to prove the webhook remains healthy after rejection.

## Cleanup

Delete the cluster-scoped webhook configurations **before** deleting their
Service or namespaces, then remove only the dedicated test namespaces:

```sh
kubectl delete mutatingwebhookconfiguration test-mutating-webhook --ignore-not-found
kubectl delete validatingwebhookconfiguration test-validating-webhook --ignore-not-found
kubectl delete namespace test-webhook-target test-webhook-control --ignore-not-found
rm -f test-admission.key test-admission.crt
```
