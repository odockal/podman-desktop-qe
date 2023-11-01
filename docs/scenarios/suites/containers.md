# Containers functionality verification steps

## Get an image
You can use some of the images available through [images scenario](https://github.com/odockal/podman-desktop-qe/blob/main/docs/scenarios/suites/images.md#example-images-for-various-purposes).

### Images to test and what are the options leading to a created container
In this scenario, we would like to make sure, that we can start a container (run an image) from multiple sources.
1. Pull image + Run image -> 1 container
2. Build an image from containerfile + run the image -> 1 container
3. Start an application that consists of at least two images (redis-flask for example)
4. We can see compose created containers (see. compose scenario)
5. Play Kubernetes YAML option that produces containers and pod(s)
6. Deploying containers to a Kubernetes cluster

### Containers verification options
1. Open Images page and find particular image
2. Run an image(s)
* from the images table on particular image row - action Run 
* from an image details page
* Containers page -> Create - it is just a redirect to the Images page
3. Verify that container is present in the Containers page
4. Verify the expected state of the container (should it be running? or in exited state?)
5. Verify image name is correct one, we got all sort of actions available on the container
6. Enter container details -> check all tabs and actions available
7. If the container is exposing a port, try to reach the app on the port via container's action -> open in browser
8. Try to look at terminal -> if the container is running
9. Stop the container - verify
10. Start the container - verify
11. Restart the container - verify
12. Deploy to kubernetes - verify
13. Create a pod by selectin one or more containers
14. Pod's containers are marked in Containers Page
15. Compose created containers are marked well
16. Delete the container works, deleting multiple containers work
17. Prune containers works
18. Play Kubernets Yaml option works