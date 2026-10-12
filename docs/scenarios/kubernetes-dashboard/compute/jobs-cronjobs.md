# Job and CronJob lifecycle

## Goal

Verify completion, details, recurring scheduling, suspend/resume, and cleanup
for batch resources.

## Setup

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test-compute-batch
---
apiVersion: batch/v1
kind: Job
metadata:
  name: test-job
  namespace: test-compute-batch
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: job
          image: registry.access.redhat.com/ubi9/ubi-minimal:latest
          command: ["sh", "-c", "echo test-job-complete"]
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: test-cron
  namespace: test-compute-batch
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: cron
              image: registry.access.redhat.com/ubi9/ubi-minimal:latest
              command: ["sh", "-c", "date; echo test-cron"]
```

## Dashboard workflow

1. Select `test-compute-batch`, then open **Compute → Jobs**. `test-job`
   must reach Completed with `1/1` completions and remain visible. Verify
   **Summary**, **Inspect**, and **Patch**, then delete it and confirm its Pod
   also disappears.
2. Open **Compute → CronJobs**. `test-cron` must show the every-minute
   schedule and a populated Last Scheduled value after one minute.
3. Open details and patch `suspend: false` to `suspend: true`. Verify no new
   Job is created while suspended. Patch it back to `false`, verify scheduling
   resumes, then delete the CronJob.

## Cleanup

```sh
kubectl delete namespace test-compute-batch --ignore-not-found
```
