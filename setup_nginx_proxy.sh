#!/bin/bash

# Step 1: Install Nginx if not installed
if ! command -v nginx &> /dev/null
then
    echo "Nginx not found, installing..."
    sudo apt update && sudo apt install -y nginx
else
    echo "Nginx is already installed."
fi

# Step 2: Create Nginx Reverse Proxy Configuration
echo "Creating Nginx reverse proxy configuration..."
sudo bash -c 'cat > /etc/nginx/sites-available/sigstore-dex' <<EOF
server {
    listen 6000;
    server_name sigstore-dex;

    location / {
        proxy_pass http://127.0.0.1:6001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Step 3: Enable the Configuration
echo "Enabling Nginx site configuration..."
sudo ln -s /etc/nginx/sites-available/sigstore-dex /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Step 4: Update /etc/hosts
echo "Updating /etc/hosts..."
echo "127.0.0.1 sigstore-dex" | sudo tee -a /etc/hosts

echo "Setup complete. Nginx should now proxy requests to sigstore-dex:6000."
