FROM debian:latest

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


# Install Dex
RUN mkdir -p ~/go/src/github.com/dexidp/ && cd "$_" \
    && git clone https://github.com/dexidp/dex.git \
    && cd dex \
    && make build \
    && cp bin/dex /usr/local/bin/ 
    

RUN mkdir -p /var/dex/ \
    && mkdir -p /etc/dex/ 

# Expose necessary ports
EXPOSE 6000

# Copy the start script into the container
COPY start-dex.sh /usr/local/bin/start-dex.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start-dex.sh

# Set the entrypoint to the start script
ENTRYPOINT ["/usr/local/bin/start-dex.sh"]