#!/bin/bash

# Default values
number=5
image="alpine"
timestamp=false

# Parse command-line arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        -h|--help)
            echo "Insert number of containers to be created"
            echo "Optional parameters:"
            echo "  -n, --number   Number of containers to create (default: 5)"
            echo "  -i, --image    Docker image to use for containers (default: alpine)"
            echo "  -t, --timestamp  Add timestamp to container names"
            exit 0
            ;;
        -n|--number)
            if [[ ! -z "$2" && "$2" =~ ^[0-9]+$ ]]; then
                number="$2"
                shift
            else
                echo "Error: Missing or invalid argument for $1 option"
                exit 1
            fi
            ;;
        -i|--image)
            if [[ ! -z "$2" && "$2" != -* ]]; then
                image="$2"
                shift
            else
                echo "Error: Missing or invalid argument for $1 option"
                exit 1
            fi
            ;;
        -t|--timestamp)
            timestamp=true
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
    shift
done

# Function to return current date with timestamp
get_timestamp() {
  date +"%Y-%m-%d_%H-%M-%S"
}

# Function to generate random string
randomize_name() {
  length=$(( $RANDOM % 255 + 1 ))
  tr -dc A-Za-z0-9 </dev/urandom | head -c $length
}

# Function to generate container name
get_container_name() {
  name="$(randomize_name)"
  if [ "$timestamp" = true ]; then
    name="$name-$(get_timestamp)"
  fi
  echo "$name"
}

echo "Pulling an image: ${image}"
podman pull ${image}

echo "Create $number containers"
for ((i=1; i<=$number; i++)); do
  container_name="$image-$(get_container_name)"
  echo "Creating container $i with name '${container_name:0:20}...' from '$image'"
  podman run --name "$container_name" ${image}
done
