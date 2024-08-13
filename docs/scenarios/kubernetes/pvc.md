# Verification of the PVC Page in Podman Desktop Using Kind

Resource: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

1. Start Kind Cluster in Podman Desktop
2. Set kubecontext to the kind cluster
3. Open Kind control plane container's terminal
4. Create a folder structure: `/mnt/data'
5. Create a file in the folder: `echo "Hello from Kind storage!" > /mnt/data/index.html`
6. Use Apply Yaml feature in Podman desktop -> choose `persistentVolume.yaml` file from this folder
7. Check that volume was created (requires `kubectl`) -> `kubectl get pv -A`
```
kubectl get pv -A  
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
task-pv-volume   1Gi        RWO            Retain           Available           manual         <unset>                          86s
```
8. Apply PVC -> `pvc.yaml`
9. Check the output now:
```
kubectl get pv -A
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
task-pv-volume   1Gi        RWO            Retain           Bound    default/task-pv-claim   manual         <unset>  
```
10. Assert that PVC actually appears in the Podman Desktop - PVC Page
11. Investigate information on the Summary page
12. Deploy a `pod-pvc.yaml` to a kubernetes cluster
13. Choose kind to deploy yaml to...
14. Wait for pod (`task-pv-pod`) to get up
15. Go to Terminal Tab of deployed pod, run: `curl http:localhost`
16. Assert: we can see `Hello from Kind storage` message
17. Delete all resources via Podman Desktop

ToDO: It would be awesome to use the ingress controller to enable the message to be accessible on the host's `localhost:9090`.