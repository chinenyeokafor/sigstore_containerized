
FROM debian:11

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update -y \
    && apt-get install -y mariadb-server git redis-server haproxy certbot wget curl

# Download and install the latest version of Go
RUN wget https://dl.google.com/go/go1.24.0.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Set up environment variables for Go
ENV PATH="/usr/local/go/bin:${PATH}"

# Clone and build Rekor
RUN mkdir -p ~/go/src/github.com/sigstore \
    && cd ~/go/src/github.com/sigstore \
    && git clone https://github.com/sigstore/rekor.git \
    && cd rekor \
    && go build -o rekor-cli ./cmd/rekor-cli \
    && cp rekor-cli /usr/local/bin/ \
    && go build -o rekor-server ./cmd/rekor-server \
    && cp rekor-server /usr/local/bin/


# Install Trillian components
RUN go install github.com/google/trillian/cmd/trillian_log_server@latest \
    && cp ~/go/bin/trillian_log_server /usr/local/bin/ \
    && go install github.com/google/trillian/cmd/trillian_log_signer@latest \
    && cp ~/go/bin/trillian_log_signer /usr/local/bin/

# Expose necessary ports
EXPOSE 8090 8091 8190 8191 3000

# Copy the entrypoint script
COPY start-rekor.sh /rekor_entrypoint.sh
RUN chmod +x /rekor_entrypoint.sh


# Script to start all services
RUN echo "#!/bin/bash" > /start_services.sh && \
    echo "trillian_log_server -http_endpoint=localhost:8090 -rpc_endpoint=localhost:8091 --logtostderr &" >> /start_services.sh && \
    echo "trillian_log_signer --logtostderr --force_master --http_endpoint=localhost:8190 -rpc_endpoint=localhost:8191 --batch_size=1000 --sequencer_guard_window=0 --sequencer_interval=200ms &" >> /start_services.sh && \
    echo "rekor-server serve --rekor_server.address=0.0.0.0 --trillian_log_server.port=8091 &" >> /start_services.sh && \
    echo "wait" >> /start_services.sh && \
    chmod +x /start_services.sh


# Set the entrypoint script
ENTRYPOINT ["/rekor_entrypoint.sh"]


