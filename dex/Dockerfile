FROM debian:11

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update -y \
    && apt-get remove -y --purge man-db \
    && apt-get install -y make git gcc wget curl

# Download and install the latest version of Go
RUN wget https://dl.google.com/go/go1.24.0.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Set up environment variables for Go
ENV PATH="/usr/local/go/bin:${PATH}"

# Ensure that Go is installed and in PATH
RUN echo $PATH
RUN go version

# Install Dex
RUN mkdir -p ~/go/src/github.com/dexidp/ && cd "$_" \
    && git clone https://github.com/dexidp/dex.git \
    && cd dex \
    && make build \
    && cp bin/dex /usr/local/bin/ 

RUN mkdir -p /var/dex/ \
    && mkdir -p /etc/dex/ \
    && echo "\
issuer: http://localhost:5556\n\
storage:\n\
  type: sqlite3\n\
  config:\n\
    file: /var/dex/dex.db\n\
web:\n\
  http: 127.0.0.1:5556\n\
frontend:\n\
  issuer: sigstore\n\
  theme: light\n\
logger:\n\
  level: \"debug\"\n\
  format: \"json\"\n\
oauth2:\n\
  responseTypes: [ \"code\" ]\n\
  skipApprovalScreen: false\n\
  alwaysShowLoginScreen: true\n\
staticClients:\n\
  - id: sigstore\n\
    public: true\n\
    name: 'sigstore'\n\
connectors:\n\
  - type: github\n\
    id: github-sigstore-test\n\
    name: GitHub\n\
    config:\n\
      clientID: ${GITHUB_CLIENT_ID}\n\
      clientSecret: ${GITHUB_CLIENT_SECRET}\n\
      redirectURI: http://localhost:5556/callback\n\
" > /etc/dex/dex-config.yaml

# Expose necessary ports
EXPOSE 6000

# Start Dex server
CMD ["dex", "serve", "--web-http-addr=0.0.0.0:6000", "/etc/dex/dex-config.yaml"]
