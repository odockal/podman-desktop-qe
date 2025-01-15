# Port forwarding testing scenario

## Prerequisites
1. Podman installed and machine running
2. Container created, must support port forwarding (ex. docker.io/httpd for manual testing)
3. Cluster created (Kind/Minikube)
4. Pod deployed on the cluster without ingress controller for better stability

## Adding and verifying a port forwarding configuration
1. Go to the Pod summary page (or Kubernetes Services/Deployments Pod details page), and create a port forwarding 
2. Open and verify the configuration 
    - Host is reachable
    - App works at the designated port
3. Go to Kubernetes Pod forwarding page and verify 
    - Configuration is visible in the list
    - Local and remote ports are correct
    - Forwarding type is correct (depending on which page you created the configuration from)

## Deleting configuration
1. Go back to Pod summary page (or Kubernetes Services/Deployments Pod details page), and remove the configuration
2. Verify configuration on the designated port doesn't connect anymore
3. Verify configuration was removed from Kubernetes Port forwarding page

## Unit test 
For running the developer unit test follow https://github.com/podman-desktop/podman-desktop/pull/7379