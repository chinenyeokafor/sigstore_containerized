#!/bin/bash
set -e

# Start MariaDB in the background
mysqld_safe > /dev/null 2>&1 &

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
for i in {30..0}; do
    if mysqladmin ping > /dev/null 2>&1; then 
        echo "MariaDB is up!"
        break
    fi
    echo "Still waiting for MariaDB..."
    sleep 1
done

# Run database setup
echo "Running database setup..."
cd /usr/local/bin/
./createdb.sh


# Start Trillian services
trillian_log_server -http_endpoint=localhost:8090 -rpc_endpoint=localhost:8091 --logtostderr &
trillian_log_signer --logtostderr --force_master --http_endpoint=localhost:8190 -rpc_endpoint=localhost:8191 --batch_size=1000 --sequencer_guard_window=0 --sequencer_interval=200ms &

# Wait for Trillian to be ready
sleep 5

# Create a Trillian log tree
LOG_ID=$(createtree --admin_server localhost:8091)

# Generate CTFE config
mkdir -p /etc/ctfe-config/
cat > /etc/ctfe-config/ct.cfg <<EOF
config {
  log_id: ${LOG_ID}
  prefix: "sigstore"
  roots_pem_file: "/shared-fulcio-config/fulcio-root.pem"
  private_key: {
    [type.googleapis.com/keyspb.PEMKeyFile] {
       path: "/etc/ctfe-config/privkey.pem"
       password: "p6ssw0rd"
    }
  }
}
EOF

# Start CTFE server
exec ct_server -logtostderr -log_config /etc/ctfe-config/ct.cfg -log_rpc_server localhost:8091 -http_endpoint 0.0.0.0:6105
