# Podman V4 to Podman V4 migration paths

## Possible migration paths

### Path 0

Upgrading the podman from v4. to v5 without stopping the machines.

0. Podman v4 installed, Podman machine started
1. Enable experimental flag for Podman v5
2. Go to dashboard and press install button
3. You are asked to stop the machines
4. No
5. Installation is canceled

### Path 1

Upgrading with podman machine started/stopped without wiping out the data

0. Podman v4 installed, Podman machine started
1. Enable experimental flag for Podman v5
2. Go to dashboard and press install button
3. You are asked to stop the machines
4. Yes
5. Proceed with installation
6. Do not accept the wiping all the data from actual podman machines - skip
7. Finish the installation
8. TBD: so far, machine are available, shows version 5 in the UI, but ie. it is not possible to start the machine., what else?

### Path 2

Upgrading with podman machine started/stopped with wiping out the data

0. Podman v4 installed, Podman machine started
1. Enable experimental flag for Podman v5
2. Go to dashboard and press install button
3. You are asked to stop the machines
4. Yes
5. Proceed with installation
6. Accept the wiping all the data from actual podman machines
7. Finish the installation
8. Verification -> create new machine, etc.

### Path 3

Having Podman v4 installed via PD or installer, machine started, installing Podman v5 using installer - no machine rm prior of podman v5 installation

0. Podman v4 installed, Podman machine started
1. Download and install podman v5
2. run podman machine reset command (as suggested in the guide - ephemeral images/containers)
3. Start up Podman Desktop
4. Check version of podman installed
5. Create new machine
6. Verification

### Path 4

Having Podman v4 installed via PD or installer, machine started, manually removing the machines, installing Podman v5 using installer

0. Podman v4 installed, Podman machine started
1. remove all machines (as suggested in the guide - using not ephemeral images/containers), save the images/containers so they can be loaded up/imported in new version
2. Download and install podman v5
3. run podman machine reset command (as suggested in the guide - ephemeral images/containers)
4. Start up Podman Desktop
5. Check podman version installed
7. Create new machine
8. Import/load images/containers
10. Verification

### Path 5

Installing Podman V5 using Podman Dekstop without previous installation of podman and without experimental flag enabled

0. No podman v4 and no machine present
1. Install podman desktop
2. Do not enabled experimental flag (Flag should have not impact on what version will be installed)
3. Podman Desktop (1.9.0) offers you to install podman v5 via installer
4. Enable experimental flag
5. Podman Desktop (1.9.0) let you to install podman v5 via installer
6. Install podman v5
7. Podman installed is in version 5 (dashboard)
8. Verify by creating podman machine in v5 version

### Path 6 

Podman Desktop Running, podman v4 installed with an installer outside of podman desktop, enabling experimental flag and installing new podman v5 (https://github.com/containers/podman-desktop/issues/6598)

0. No podman v4 and no machine present
1. Install podman desktop
2. Start podman desktop
3. Install podman v4 via installer
4. No update button appears
5. Enable experimental flag
6. Update button to podman v5 is present
7. Update to newer podman
8. Create new machine with new podman and verify it works

### Path 7: Detect old (v4) podman machine on new podman v5 with Podman Desktop (https://github.com/containers/podman-desktop/pull/6570)

0. Having podman v4 installed
1. create a machine using podman v4 via cli
2. install podman v5
3. create new machine using new podman: `podman machin init v5` -> I got an error with former json of the machine created by older version of podman -> `json: cannot unmarshal string into Go struct field MachineConfig.ImagePath of type define.VMFile`
4. Start up podman desktop
5. In Podman desktop there should be a dialog opened asking you to remove old machine only


## Paths with save/load images and export/import containers

### Path Images

Upgrading with podman machine started/stopped with wiping out the data, saving the images locally and loading them up again in the new machine (from blog post), functionality here: https://github.com/containers/podman-desktop/issues/6542

0. Podman v4 installed, podman machine started with some image I want to preserve
1. Save the image
2. Enable experimental flag for Podman v5
3. Go to dashboard and press install button
4. Accept installation of Podman v5.
5. Accept the wiping all the data from actual podman machines
6. Finish the installation
7. Create new machine
8. Load the saved image
9. Verify everything is working

### Path Containers

Upgrading with podman machine started/stopped with wiping out the data, and testing the export/import of the container

0. Podman v4 installed, podman machine started with some container to export
1. Export the container
2. Enable experimental flag for Podman v5
3. Go to dashboard and press install button
4. Accept installation of Podman v5.
5. Accept the wiping all the data from actual podman machines
6. Finish the installation
7. Create new machine
8. import the containerfile
9. Verify everything is working