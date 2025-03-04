#!/bin/bash

set -e  # Exit on error
set -o pipefail  # Fail if any command in a pipeline fails

# Ensure script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo."
   exit 1
fi

# Update and install dependencies
apt-get update -y && \
apt-get remove -y --purge man-db && \
apt-get install -y curl wget

# Install Go
GO_VERSION="1.24.0"
wget -qO /tmp/go.tar.gz "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz"
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
export PATH="/usr/local/go/bin:${PATH}"

# Install Cosign
/usr/local/go/bin/go install github.com/sigstore/cosign/cmd/cosign@latest
cp ~/go/bin/cosign /usr/local/bin/cosign

# Verify installation
cosign version

echo "Installation complete."
