# Kubernetes Networking Test Scenario

This test scenario walks through deploying an application, exposing it using a ClusterIP Service, and configuring external access through an Ingress resource.

---

## Prerequisites

- A running Kubernetes or OpenShift cluster (e.g., Kind, Minikube, or OpenShift Local).
- An active Ingress controller (e.g., Contour) running in the cluster.

---

## Step 1: Deploy the Application

1. **Apply the Deployment Resource**
   - Use the following resource:  
     [`test-deployment-resource.yaml`](https://github.com/odockal/podman-desktop-qe/blob/main/docs/scenarios/kubernetes/resources/test-deployment-resource.yaml)
   - Apply it using the **"Apply YAML"** button on the **Kubernetes** page.

2. **Verify Deployment Status**
   - Go to the **Kubernetes Pods** page.
   - Confirm that all pods are in a `Running` state.
   - The deployment resource should display as `Running`.

---

## Step 2: Create and Verify the Service

1. **Apply the Service Resource**
   - Use the following resource:  
     [`test-service-resource.yaml`](https://github.com/odockal/podman-desktop-qe/blob/main/docs/scenarios/kubernetes/resources/test-service-resource.yaml)
   - Apply it using the **"Apply YAML"** button on the **Kubernetes** page.

2. **Confirm the Service is Bound to the Deployment**
   - Go to the **Services** page.
   - Verify that the service is listed and in a `Running` state.
   - In the **Service details**, check the **Selector** field — it should display:  
     ```
     app: test-deployment-resource
     ```

3. **Test Service Functionality**

   - **Option 1: Port Forwarding in Podman Desktop**
     - Open the **Services** tab.
     - Select the created service.
     - Click **Port Forwarding** and forward the service to **localhost:5000**.
     - Open your browser and go to:  
       [http://localhost:5000/](http://localhost:5000)
     - You should see the **"Welcome to nginx"** page.

   - **Option 2: Use an Ingress Resource**
     - Skip port forwarding and proceed to the next step to apply the Ingress resource.

---

## Step 3: Configure and Test Ingress

1. **Verify the Ingress Controller is Running**
   - Run the following command:
     ```bash
     kubectl get pods -n projectcontour
     ```
   - Ensure the `envoy` and `contour` pods are in a `Running` state.

2. **Apply the Ingress Resource**
   - Use the following resource:  
     [`test-ingress-resource.yaml`](https://github.com/odockal/podman-desktop-qe/blob/main/docs/scenarios/kubernetes/resources/test-ingress-resource.yaml)
   - Apply it using the **"Apply YAML"** button on the **Kubernetes** page.

3. **Verify the Ingress Appears in Podman Desktop**
   - Open the **Ingresses & Routes** page.
   - Confirm the new Ingress is listed and its status is `Running`.

4. **Access the Application Through Ingress**
   - Open your browser and go to:  
     [http://localhost:9090/](http://localhost:9090)
   - Expected result: the **nginx welcome page** should appear.

---

## Notes

- Ensure **port 9090** is not already used by another service on your machine.
- If the Ingress controller is not running, the pod will not be accessible through the Ingress resource. Make sure it's correctly installed and active before proceeding.
