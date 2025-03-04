FROM debian:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/go/bin:${PATH}"

# Install dependencies
RUN apt-get update -y && \
    apt-get remove -y --purge man-db && \
    apt-get install -y mariadb-server git wget

# Install Go
RUN wget -qO /tmp/go.tar.gz https://dl.google.com/go/go1.24.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Install Trillian and CTFE components
RUN go install github.com/google/trillian/cmd/trillian_log_server@latest && \
    go install github.com/google/trillian/cmd/trillian_log_signer@latest && \
    go install github.com/google/trillian/cmd/createtree@latest && \
    go install github.com/google/certificate-transparency-go/trillian/ctfe/ct_server@latest && \
    cp /root/go/bin/trillian_log_server /usr/local/bin/ && \
    cp /root/go/bin/trillian_log_signer /usr/local/bin/ && \
    cp /root/go/bin/createtree /usr/local/bin/ && \
    cp /root/go/bin/ct_server /usr/local/bin/


# Download database scripts (they will be run at startup)
RUN wget -qO /usr/local/bin/createdb.sh https://raw.githubusercontent.com/sigstore/rekor/main/scripts/createdb.sh && \
    wget -qO /usr/local/bin/storage.sql https://raw.githubusercontent.com/sigstore/rekor/main/scripts/storage.sql && \
    chmod +x /usr/local/bin/createdb.sh

# Generate CTFE key pair
RUN mkdir -p /etc/ctfe-config && \
    openssl ecparam -genkey -name prime256v1 -noout -out unenc.key && \
    openssl ec -in unenc.key -out /etc/ctfe-config/privkey.pem -des3 -passout pass:p6ssw0rd && \
    openssl ec -in /etc/ctfe-config/privkey.pem -pubout -out /etc/ctfe-config/ctfe_public.pem -passin pass:p6ssw0rd && \
    rm unenc.key && \
    mkdir -p /shared-ctlog-config && \
    cp /etc/ctfe-config/ctfe_public.pem  /shared-ctlog-config

# Copy entrypoint script
COPY start_services.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_services.sh

# Expose necessary ports
EXPOSE 8090 8091 8190 8191 6105 3306

# Set entrypoint
CMD ["/usr/local/bin/start_services.sh"]
