FROM debian:11

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update -y \
    && apt-get remove -y --purge man-db \
    && apt-get install -y git gcc wget make

# Download and install the latest version of Go
RUN wget https://dl.google.com/go/go1.24.0.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Set up environment variables for Go
ENV PATH="/usr/local/go/bin:${PATH}"


# Install Fulcio
RUN go install github.com/sigstore/fulcio@v1.6.6 \
    && cp ~/go/bin/fulcio /usr/local/bin/

# Configure File CA setup
RUN openssl ecparam -genkey -name prime256v1 -noout -out unenc.key \
    && openssl ec -in unenc.key -out file_ca_key.pem -des3 -passout pass:p6ssw0rd \
    && openssl ec -in file_ca_key.pem -pubout -out file_ca_pub.pem -passin pass:p6ssw0rd \
    && openssl req -new -x509 -days 365 -extensions v3_ca -key file_ca_key.pem -out fulcio-root.pem -passin pass:p6ssw0rd -subj "/C=US/ST=IN/L=City/O=Organization/OU=Unit/CN=fulcio-root" \
    && rm unenc.key \
    && mkdir -p /shared-fulcio-config \
    && cp file_ca_key.pem file_ca_pub.pem fulcio-root.pem /shared-fulcio-config/

RUN mkdir -p /root/fulcio-config && \
    cat <<EOF > /root/fulcio-config/config.json
{
  "OIDCIssuers": {
    "http://sigstore-dex:6000": {
      "IssuerURL": "http://sigstore-dex:6000",
      "ClientID": "sigstore",
      "Type": "email"
    }
  }
}
EOF


# Expose necessary ports
EXPOSE 5000


# Start Fulcio CA
CMD ["fulcio", "serve", "--config-path=/root/fulcio-config/config.json", "--ca=fileca", "--fileca-cert=/shared-fulcio-config/fulcio-root.pem", "--fileca-key=/shared-fulcio-config/file_ca_key.pem", "--fileca-key-passwd=p6ssw0rd", "--ct-log-url=http://sigstore-ctlog:6105/sigstore", "--host=0.0.0.0", "--port=5000"]
