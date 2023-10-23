# Testing scenarios using kube-context

## Prerequisities
1. Podman installed
2. Having set an access to the Kubernetes/OCP cluster via kubeconfig file

Any combination of the testing suites can be used. 
General guide for simple app. deployment to verify extension's functionality can be found [here](https://github.com/odockal/podman-desktop-qe/docs/scenarios/suites/)

## Instalation and kube context
1. Start up podman desktop
2. Podman machine is initialized and running
3. Pull an image of `quay.io/ubi8/httpd-24`
5. Start the container from an image - keep port 8080:8080 for `httpd`
6. Check container is running, `localhost:8080`, log shows right output, terminal is available, kube is present, open in browser.
7. Mark container and create a pod
8. Check Pod is running, former container is stopped, there is new containers group with label `pod` present 
9. The app. is available on `localhost:8080`, inspect, kube, summary also show correct information
10. Choose proper kube context - using system tray or tool bar item in the Podman Desktop
11. Enter the pod and press Deploy to Kubernetes
12. On the page, based on type of the cluster, choose proper service exposure (route or ingress controller)
13. Deploy
14. Wait for deployment to finish - should be marked running
15. Route link is present (in case of kind, nothing)
16. Done
17. Verify that app is running on given port or route
18. Clean up - stop pods, remove pods, remove containers, remove images, volumes...

## Resources
* [Kube config reference guide](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)