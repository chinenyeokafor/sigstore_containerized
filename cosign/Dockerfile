FROM debian:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/go/bin:${PATH}"

# Install dependencies
RUN apt-get update -y && \
    apt-get remove -y --purge man-db && \
    apt-get install -y curl wget 

# Install Go
RUN wget -qO /tmp/go.tar.gz https://dl.google.com/go/go1.24.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Install Cosign
RUN go install github.com/sigstore/cosign/cmd/cosign@latest && \
    cp ~/go/bin/cosign /usr/local/bin/cosign


CMD ["tail", "-f", "/dev/null"]

