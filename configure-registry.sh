#!/bin/bash

# Step 1: Create a simple Dockerfile
echo "Creating Dockerfile..."
cat > Dockerfile <<EOF
FROM alpine
CMD ["echo", "Hello Sigstore!"]
EOF

# Step 2: Build the Docker image
echo "Building the Docker image..."
docker build -t sigstore-thw:latest .

# Step 3: Set up your GitHub Personal Access Token (PAT)
echo "Set your GitHub Personal Access Token..."
export CR_PAT="YOUR_TOKEN"

# Step 4: Login to GitHub Container Registry (ghcr.io)
echo "Logging in to GitHub Container Registry..."
echo -n "$CR_PAT" | docker login ghcr.io -u <github_user> --password-stdin

# Step 5: Tag the Docker image for the GitHub Container Registry
echo "Tagging the Docker image..."
docker tag sigstore-thw:latest ghcr.io/<github_user>/sigstore-thw:latest

# Step 6: Push the Docker image to GitHub Container Registry
echo "Pushing the Docker image to GitHub Container Registry..."
docker push ghcr.io/<github_user>/sigstore-thw:latest

echo "Docker image pushed successfully!"
