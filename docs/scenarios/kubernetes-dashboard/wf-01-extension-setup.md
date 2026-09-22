# WF-01: Extension Setup & Connectivity

This scenario verifies that the Kubernetes Dashboard extension installs correctly, responds to enable/disable toggling, and automatically reconnects when a valid kubeconfig is provided.

## Prerequisites

- Podman Desktop installed.
- A Kind (or other local) Kubernetes cluster available.
- No cluster connection is required for steps 1–3.

## Scenario Steps

1. **Install the extension from the marketplace**  
   Open the Extensions page in Podman Desktop and find the Kubernetes Dashboard extension. Install it.  
   **Expected:** The extension card status changes to ACTIVE with a green badge. The extension details page shows no "Error" tab.

2. **Disable the extension**  
   On the extension details page, toggle the extension off.  
   **Expected:** The Dashboard icon disappears from the left navigation bar. The webview is inaccessible.

3. **Re-enable the extension**  
   Toggle the extension back on.  
   **Expected:** The Dashboard icon returns in the left navigation bar. The webview shows either "Connected" or the no-cluster screen.

4. **Connect to a Kind cluster**  
   Open Preferences → Kubernetes → Kubeconfig and select a valid kubeconfig pointing to your Kind cluster.  
   **Expected:** The context name appears in the Podman Desktop status bar. The Dashboard transitions to the Connected state with non-zero tile counts (Deployments, Pods, Services, etc.).

5. **Remove the kubeconfig**  
   Select an empty or invalid kubeconfig in Preferences → Kubernetes → Kubeconfig.  
   **Expected:** The Dashboard transitions to the no-cluster screen, offering Kind/minikube cluster creation options. Tiles disappear.

6. **Restore the valid kubeconfig**  
   Re-select the valid kubeconfig.  
   **Expected:** The Dashboard reconnects automatically. Tile counts reappear without a manual refresh.
