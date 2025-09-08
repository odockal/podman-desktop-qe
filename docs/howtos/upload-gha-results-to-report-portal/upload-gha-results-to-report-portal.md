# How to Trigger OpenShift Pipelines from GitHub Actions Workflows

This document describes how to automatically run an OpenShift pipeline after a GitHub Actions workflow completes, specifically for uploading test artifacts to Report-Portal. The solution uses a GitHub App to send webhooks and Tekton Triggers on OpenShift to process the events.

---

## 1. GitHub Configuration

First, you need to set up a GitHub App to send webhooks to your OpenShift cluster. This app will act as the communication link between your GitHub repository and your OpenShift environment.

- Create the App: Navigate to your organization or user settings in GitHub, go to Developer settings -> GitHub Apps, and click New GitHub App.
- Set the Webhook URL: This is a critical step. For your OpenShift cluster to receive webhooks from GitHub (which is on the public internet), you'll need a service that can expose a private endpoint. The document uses gosmee. The URL provided by gosmee is what you'll enter in the Webhook URL field.
- Configure a Webhook Secret: Provide a strong, random secret string. This secret is used to secure the communication; the EventListener on OpenShift will use this same secret to verify that the webhook payload is from your trusted GitHub App.
- Permissions and Events: To get the necessary information from workflow runs, you only need to grant read-only access to "Actions." Then, subscribe to the workflow_run event. This ensures a webhook is sent every time a workflow run event occurs in your repository.

Once configured, you can install the app in the repositories you want to monitor.

---

## 2. OpenShift Resources

To receive and act on the GitHub webhook, you must have the OpenShift Pipelines operator installed. This operator provides Tekton Pipelines and Tekton Triggers, which are the core components of this solution. You will then create the following resources:

---

### Smee Deployment

This Kubernetes Deployment runs the gosmee client. This client is a reverse proxy that creates a secure tunnel between the public gosmee server and your private OpenShift cluster. It forwards webhooks received by the public URL to your internal EventListener service.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: gosmee-client-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gosmee-client
  template:
    metadata:
      labels:
        app: gosmee-client
    spec:
      containers:
        - name: gosmeeclient-container
          image: ghcr.io/chmouel/gosmee:latest
          imagePullPolicy: IfNotPresent
          args: ["client", "https://hook.pipelinesascode.com/sVHMVcenlmCs", "http://el-github-listener.pac.svc.cluster.local:8080"]

---

### EventListener

The EventListener is the entry point for the webhook on your OpenShift cluster. It listens for incoming HTTP requests and triggers a Tekton pipeline if the request meets specific criteria.

The key components here are the interceptors, which act as filters and validators:

- The github interceptor validates the payload's signature using the webhook secret, ensuring the request is from your GitHub App.
- The cel interceptor provides further filtering using a Common Expression Language (CEL) filter. The filter ensures the pipeline only triggers on a workflow_run that has a completed action, has the name pr-check, and a conclusion of either failure or success.

apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-listener
  namespace: pac
spec:
  serviceAccountName: tekton-triggers-sa
  triggers:
    - name: github-listener
      interceptors:
        - ref:
            name: github
            kind: ClusterInterceptor
          params:
            - name: secretRef
              value:
                secretName: pipeline-secret
                secretKey: secretToken
            - name: eventTypes
              value: ["workflow_run"]
        - ref:
            name: cel
            kind: ClusterInterceptor
          params:
            - name: filter
              value: "body.action == 'completed' && body.workflow.name == 'pr-check' && body.workflow_run.conclusion in ['failure', 'success']"
      bindings:
        - ref: github-workflow-binding
      template:
        ref: github-workflow-template

---

### TriggerBinding

The TriggerBinding extracts specific data from the incoming webhook payload and maps it to parameters for the pipeline. This allows passing dynamic information about the GitHub workflow run (ID, URL, conclusion, etc.) to your pipeline.

apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-workflow-binding
  namespace: pac
spec:
  params:
    - name: workflow-run-name
      value: $(body.workflow_run.name)
    - name: workflow-id
      value: $(body.workflow.id)
    - name: workflow-run-id
      value: $(body.workflow_run.id) 
    - name: workflow-name
      value: $(body.workflow.name)
    - name: workflow-run-conclusion
      value: $(body.workflow_run.conclusion)
    - name: workflow-run-artifacts
      value: $(body.workflow_run.artifacts_url)
    - name: target-repo
      value: $(body.repository.full_name)
    - name: workflow-run-url
      value: $(body.workflow_run.html_url)

---

### TriggerTemplate

The TriggerTemplate defines the PipelineRun resource that will be created by the EventListener. It takes the parameters from the TriggerBinding and populates the PipelineRun’s configuration, including pipeline parameters, workspaces, and secrets.

apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: github-workflow-template
  namespace: pac
spec:
  params:
    - name: workflow-name
    - name: workflow-id
    - name: workflow-run-name
    - name: workflow-run-id
    - name: workflow-run-conclusion
    - name: workflow-run-artifacts
    - name: target-repo
    - name: workflow-run-url
    - name: qe-workspace-subpath
      default: 'default-path'
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: upload-gha-results-v2-amisskii-
      spec:
        pipelineRef:
          name: pde2e-gha-results-upload
        params:
        - name: workflow-name
          value: $(tt.params.workflow-name)
        - name: workflow-id
          value: $(tt.params.workflow-id)
        - name: workflow-run-name
          value: $(tt.params.workflow-run-name)
        - name: workflow-run-id
          value: $(tt.params.workflow-run-id)
        - name: workflow-run-conclusion
          value: $(tt.params.workflow-run-conclusion)
        - name: workflow-run-artifacts
          value: $(tt.params.workflow-run-artifacts)
        - name: target-repo
          value: $(tt.params.target-repo)
        - name: workflow-run-url
          value: $(tt.params.workflow-run-url)
        - name: pipelinerun-url
          value: 'https://console-openshift-console.apps.gpc.ocp-hub.prod.psi.redhat.com/k8s/ns/$(context.pipelineRun.namespace)/tekton.dev~v1~PipelineRun/$(context.pipelineRun.name)'
        - name: qe-workspace-subpath
          value: $(tt.params.qe-workspace-subpath)
        workspaces:
        - name: pipelines-data
          persistentVolumeClaim:
            claimName: pipelines-data
        - name: reportportal-credentials
          secret:
            secretName: reportportal-pd
        - name: github-actions-credentials
          secret:
            secretName: github-podmandesktop-ci-bot-actions-token
        timeout: "30m"
