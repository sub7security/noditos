#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Default policies (adjust if necessary)
ufw default deny incoming
ufw default allow outgoing

# Allow trafic for P2P
ufw allow 30303
ufw allow 9000

# Allow all traffic from the Tailscale
ufw allow from 100.0.0.0/8

# Allow VPSs to access the RPCs
ufw allow from 213.199.57.24 to any port 443 #AXVPS
ufw allow from 167.235.116.175 to any port 443 #PROXMOX
ufw allow from 38.54.45.59 to any port 443 #lido-obol
ufw allow from 154.205.154.94 to any port 443 #threshold

# Specific port rules for denying
ufw deny 8545
ufw deny 8546
ufw deny 8551
ufw deny 5052
ufw deny 3000
ufw deny 9090
ufw deny 9900
ufw deny 9901
ufw deny 9902
ufw deny 80
ufw deny 443

# Enable UFW
ufw --force enable

# Reload UFW to apply changes
ufw reload

# Display status
ufw status numbered
