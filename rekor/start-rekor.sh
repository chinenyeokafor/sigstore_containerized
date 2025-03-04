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
cd /root/go/src/github.com/sigstore/rekor/scripts
./createdb.sh

# Start all services
exec /start_services.sh
