#!/bin/bash

# Check if logrotate is installed, and install it if not
if ! command -v logrotate &> /dev/null
then
    echo "logrotate could not be found, installing it now..."
    sudo apt update
    sudo apt install -y logrotate
else
    echo "logrotate is already installed"
fi

# Create the logrotate configuration file for Docker logs
LOGROTATE_CONF="/etc/logrotate.d/docker"

sudo tee $LOGROTATE_CONF > /dev/null <<EOL
/var/lib/docker/containers/*/*.log {
    rotate 30
    daily
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
EOL

sudo logrotate -f /etc/logrotate.d/docker

echo "Logrotate configuration for Docker logs has been set up successfully."
