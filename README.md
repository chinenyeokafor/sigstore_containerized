# sigstore-containerized

`sigstore-containerized` demonstrates how to build and configure a local Sigstore stack  for software artifact signing purposes. This setup is based on **Sigstore the Hard Way**, but simplified for containerized environments.

### Overview

- **Dex, Fulcio, Rekor, and CTLog** are run in containers.
- **Cosign** is run locally on the host machine.

---

### Getting Started

1. **Clone the Repository**

   To get started, clone the repository:

   ```bash
   git clone <repo-url>
   cd sigstore-containerized
   ```

2. **Configure the GitHub Container Registry**

   Set up GitHub Container Registry (ghcr.io) and create a Docker image for signing. Update the configure-registry.sh script with your GitHub username and PAT, then run the commands:

   ```bash
   chmod +x configure-registry.sh
   ./configure-registry.sh
   ```

3. **Set Up Rekor, Fulcio, and Other Components**

   Use Docker Compose to build and start all components (Rekor, Fulcio, Dex, CTLog):

   ```bash
   docker-compose up --build
   ```

   After the setup, you can verify that each component started correctly by checking the logs:

   ```bash
   docker logs sigstore-rekor
   docker logs sigstore-fulcio
   # And so on for other services
   ```

4. **Set Up Cosign (Local on Host Machine)**

   Cosign will be run locally on the host machine. First, give the `install_cosign.sh` script execute permission:

   ```bash
   chmod +x install_cosign.sh
   ```

   Then, run it with sudo to install Cosign:

   ```bash
   sudo ./install_cosign.sh
   ```

5. **Set Up Nginx Proxy**

   Since the Sigstore stack is running in containers, each component accesses others using their service names. However, Cosign is running locally on the host machine and can't resolve the dex service name. To fix this, we set up an Nginx proxy to route the requests properly.

   Make the `setup_nginx_proxy.sh` script executable:

   ```bash
   chmod +x setup_nginx_proxy.sh
   ```

   Then, run the script:

   ```bash
   ./setup_nginx_proxy.sh
   ```

6. **Signing a Container**

   Now that the infrastructure is set up, we are ready to sign a container image using the deployed stack.

   **Copy the Certificate Transparency Key**

   Copy the Certificate Transparency (CT) public key from the Docker volume to a location that doesn't require privileged access. Replace `/path/to/` and run:

   ```bash
   cp $(docker volume inspect ctlog-data --format '{{ .Mountpoint }}')/ctfe_public.pem "/path/to/ctfe_public.pem"
   ```

   Set the environment variable to point to this key:

   ```bash
   export SIGSTORE_CT_LOG_PUBLIC_KEY_FILE="/path/to/ctfe_public.pem"
   ```

   **Sign the Container**

   Finally, use the following command to sign your container image:

   ```bash
   COSIGN_EXPERIMENTAL=1 \
   cosign sign \
      --oidc-issuer=http://sigstore-dex:6000 \
      --fulcio-url=http://localhost:5000 \
      --rekor-url=http://localhost:3000 \
      sigstore-thw:latest
   ```

### Troubleshooting

- If cosign is unable to resolve service names like `sigstore-dex`, ensure that the Nginx proxy is correctly set up and running.
- Check Docker container logs to verify that each service (Rekor, Fulcio, Dex, CTLog) started successfully.
- Ensure the correct permissions are set on the CT public key.
- If you encounter "authentication required" errors, make sure you are logged in to Docker on the terminal:

   ```bash
   docker login
   ```

   Follow the prompts to authenticate.