#!/bin/bash

# BootC Parameters
bootc_name="ghcriocontainerspodmandesktopextensionbootc"
bootc_image_name="ghcr.io/containers/podman-desktop-extension-bootc"
bootc_image_tag="0.3.0"

# AI Studio parameters
studio_name="ghcrioprojectatomicaistudio"
studio_image_name="ghcr.io/projectatomic/ai-studio"
studio_image_tag="0.1.0"

# SSO Extensions Parameters
sso_name="ghcrioredhatdeveloperpodmandesktopextensionredhataccountext"
sso_image_name="ghcr.io/redhat-developer/podman-desktop-redhat-account-ext"
sso_image_tag="latest"
podman_desktop_config="$HOME/.local/share/containers/podman-desktop"

install_extension() {
    name=$1
    image_name=$2
    image_tag=$3
    tmp_folder="$name-tmp"
    archive="$name.tar"
    image_url="$image_name:$image_tag"
    # Checkout to the podman dektop config home - plugins
    if [ ! -d $podman_desktop_config ]; then
        echo "Podman Desktop config folder was not yet initialized, initializing..."
        mkdir -p $podman_desktop_config
        mkdir -p "$podman_desktop_config/plugins"
    fi
    cd "$podman_desktop_config/plugins"

    # Pull the Extension's OCI image
    podman pull $image_url
    # Create a container with overriden entrypoint to get all image layers together
    id=$(podman create $image_url --entrypoint "")
    # export container into archive
    podman export $id -o $archive

    # ALTERNATIVE - Create an archive from the image
    # This might results in multiple archives representing image layers,
    # which would need some additional changes to get them merged
    # podman save -o "$name.tar" "$image_name:$image_tag"
    # tar -xf $image_tar -C $tmp_folder
    # image_tar=$(find ./$tmp_folder/ -name "*.tar" | grep -v "layer")

    # Prepare directory structure and extract image archive into tmp folder, where we expect extension dir
    mkdir -p $tmp_folder
    tar -xf $archive -C $tmp_folder
    # move content of the extracted files into target location
    mkdir -p $name
    cp -r $tmp_folder/extension/* $name

    echo "Cleaning up tmp folders and archives"
    rm -rf $tmp_folder
    rm -rf $archive
}

echo "Installing Podman Desktop Extension BootC"
install_extension $bootc_name $bootc_image_name $bootc_image_tag

echo "Installing Podman Desktop Extension AI Studio"
install_extension $studio_name $studio_image_name $studio_image_tag

echo "Installing Podman Desktop Extension RH SSO"
install_extension $sso_name $sso_image_name $sso_image_tag
