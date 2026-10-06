# Admission webhook lifecycle

## Goal

Verify that the dashboard presents live mutating and validating webhook
configuration, and that Kubernetes invokes a TLS-backed service to mutate a
valid Pod and reject an invalid Pod.

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
  -keyout qe-v06-admission.key -out qe-v06-admission.crt \
  -subj '/CN=qe-v06-admission.qe-v06-webhook-control.svc' \
  -addext 'subjectAltName=DNS:qe-v06-admission.qe-v06-webhook-control.svc,DNS:qe-v06-admission.qe-v06-webhook-control.svc.cluster.local'

kubectl create namespace qe-v06-webhook-control
kubectl -n qe-v06-webhook-control create secret tls qe-v06-admission-tls \
  --cert=qe-v06-admission.crt --key=qe-v06-admission.key
kubectl create namespace qe-v06-webhook-target
kubectl label namespace qe-v06-webhook-target qe-v06-webhook-test=true
```
Apply the following server, Deployment, and Service. The server mutates each
accepted Pod with `qe-v06-mutated: "true"` and only accepts Pods labeled
`qe-v06-valid: "true"`.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: qe-v06-admission-server
  namespace: qe-v06-webhook-control
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
                patch = json.dumps([{"op": "add", "path": "/metadata/labels/qe-v06-mutated", "value": "true"}])
                self.respond(review, True, patch=patch)
            elif path == "/validate":
                self.respond(review, labels.get("qe-v06-valid") == "true", message="qe-v06-valid=true is required")
            else:
                self.respond(review, False, message="unknown endpoint")

    server = HTTPServer(("", 8443), AdmissionHandler)
    server.socket = ssl.wrap_socket(server.socket, certfile="/tls/tls.crt", keyfile="/tls/tls.key", server_side=True)
    server.serve_forever()
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: qe-v06-admission
  namespace: qe-v06-webhook-control
spec:
  replicas: 1
  selector:
    matchLabels:
      app: qe-v06-admission
  template:
    metadata:
      labels:
        app: qe-v06-admission
    spec:
      containers:
        - name: server
          image: python:3.12-alpine
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
            name: qe-v06-admission-server
        - name: tls
          secret:
            secretName: qe-v06-admission-tls
---
apiVersion: v1
kind: Service
metadata:
  name: qe-v06-admission
  namespace: qe-v06-webhook-control
spec:
  selector:
    app: qe-v06-admission
  ports:
    - port: 443
      targetPort: 8443
```

Wait for it to become available, then capture the CA bundle used in the next
definition:

```sh
kubectl apply -f webhook-service.yaml
kubectl -n qe-v06-webhook-control rollout status deployment/qe-v06-admission --timeout=180s
QE_V06_CA_BUNDLE="$(base64 < qe-v06-admission.crt | tr -d '\n')"
```

## Create the scoped webhook configurations

Replace `REPLACE_WITH_CA_BUNDLE` with `QE_V06_CA_BUNDLE` before applying the
following YAML. The `namespaceSelector` is mandatory: it confines both
webhooks to `qe-v06-webhook-target`.

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: qe-v06-mutating-webhook
webhooks:
  - name: mutate.qe-v06.example
    admissionReviewVersions: ["v1"]
    sideEffects: None
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        qe-v06-webhook-test: "true"
    clientConfig:
      service:
        namespace: qe-v06-webhook-control
        name: qe-v06-admission
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
  name: qe-v06-validating-webhook
webhooks:
  - name: validate.qe-v06.example
    admissionReviewVersions: ["v1"]
    sideEffects: None
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        qe-v06-webhook-test: "true"
    clientConfig:
      service:
        namespace: qe-v06-webhook-control
        name: qe-v06-admission
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
   the `qe-v06-*` entries: Service target, CA bundle, endpoint, Pod `CREATE`
   rule, selector, and `failurePolicy: Fail` must be visible.
2. In **Apply YAML**, create this valid Pod:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: qe-v06-webhook-valid
     namespace: qe-v06-webhook-target
     labels:
       qe-v06-valid: "true"
   spec:
     containers:
       - name: sleeper
         image: busybox:1.36
         command: ["sh", "-c", "sleep 3600"]
   ```

3. Switch **Compute → Pods** to `qe-v06-webhook-target`. The Pod must be
   Running. Its **Inspect** output must include `qe-v06-mutated: "true"`.
4. In **Apply YAML**, create this invalid Pod:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: qe-v06-webhook-invalid
     namespace: qe-v06-webhook-target
     labels:
       qe-v06-case: invalid
   spec:
     containers:
       - name: sleeper
         image: busybox:1.36
         command: ["sh", "-c", "sleep 3600"]
   ```

5. Apply YAML must report `qe-v06-valid=true is required`; the invalid Pod
   must not appear in the target namespace. Reapply the valid Pod under a new
   name to prove the webhook remains healthy after rejection.

## Cleanup

Delete the cluster-scoped webhook configurations **before** deleting their
Service or namespaces, then remove only the dedicated test namespaces:

```sh
kubectl delete mutatingwebhookconfiguration qe-v06-mutating-webhook --ignore-not-found
kubectl delete validatingwebhookconfiguration qe-v06-validating-webhook --ignore-not-found
kubectl delete namespace qe-v06-webhook-target qe-v06-webhook-control --ignore-not-found
rm -f qe-v06-admission.key qe-v06-admission.crt
```
