#!/bin/bash

# Define the container name and Dockerfile
CONTAINER_NAME="sigstore-rekor-test"
DOCKERFILE="Dockerfile-rekor"

# Stop the container if it is running
docker stop $CONTAINER_NAME > /dev/null 2>&1

# Remove the container if it exists
docker rm $CONTAINER_NAME > /dev/null 2>&1

# Build the Docker image
docker build -t sigstore-rekor-image -f $DOCKERFILE .

# Run the container
docker run -d --name $CONTAINER_NAME sigstore-rekor-image

# Execute into the container
docker exec -it $CONTAINER_NAME /bin/bash

