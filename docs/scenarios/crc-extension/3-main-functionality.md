# Main functionality
This document covers how to complete the test cases from the third section of the `OpenShift Local extension` test sheet. In the first test case it is presumed that the `OpenShift Local extension` and the `OpenShift Local` binaries are installed in the machine.

### OpenShift bundle/cluster can be started
- On **Settings/Resources**, make sure you have no cluster initialized. `Stop` it and delete if you do
- Go to **Settings/Preferences** and make sure you have the preset set to `openshift` in the `Extension: Red Hat OpenShift Local` section
- Go to **Settings/Resources** and click on the `Create new...` button on the `OpenShift Local` card
- A new window should open, leave the default settings and click on the `Create` button
- After a while, the OpenShift cluster should be initialized and started

### Microshift bundle/cluster can be started
Exactly like the previous test case, but changing the preset from `openshift` to `microshift`

### Stop, Start, Restart
On **Settings/Resources**, try to `Stop`, `Start`, and `Restart` the current cluster

### Preset can be changed and cluster started-restarted
- Make sure your cluster is stopped by going to the `OpenShift Local` card in **Settings/Resources** and clicking on `Stop` if the status is `RUNNING`
- Go to **Settings/Preferences** and swap the preset setting in `Extension: Red Hat OpenShift Local` to the other one 
- Go back to **Settings/Resources** and start the cluster. After a while the status should've changed from `STARTING` to `RUNNING`

### Can deploy a pod/containers (ie. httpd-24) to a cluster
Follow the steps on the [Deployment to OpenShift Local section of the README](https://github.com/crc-org/crc-extension?tab=readme-ov-file#deployment-to-openshift-local)

### Can delete the cluster
- Go to **Settings/Resources**, on the `OpenShift Local` card, click on the `Stop` button. After it has finished stopping, click on the `Delete` button
- The button `Create new...` should've appeared again in the card