#!/bin/bash

# Define the container name and Dockerfile
CONTAINER_NAME="sigstore-ctlog"
DOCKERFILE="Dockerfile"
IMAGE="sigstore-ctlog-image"

# Stop the container if it is running
docker stop $CONTAINER_NAME > /dev/null 2>&1

# Remove the container if it exists
docker rm $CONTAINER_NAME > /dev/null 2>&1

# Build the Docker image
docker build -t $IMAGE -f $DOCKERFILE .

# Run the container, mount vol to access fulcio key
docker run -d --name $CONTAINER_NAME -v fulcio-data:/shared $IMAGE

# Execute into the container
docker exec -it $CONTAINER_NAME /bin/bash

