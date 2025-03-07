#!/bin/bash

# Function to create a user, add to sudo group, and set up SSH key
setup_user() {
    local username=$1
    local ssh_key=$2

    # Create new user
    adduser --disabled-password --gecos "" $username

    # Add user to sudo group
    usermod -aG sudo $username

		# Add user to noditos group & folder
    usermod -aG noditos $username

    # Set up SSH key for the user
    mkdir -p /home/$username/.ssh
    echo $ssh_key > /home/$username/.ssh/authorized_keys
    chmod 700 /home/$username/.ssh
    chmod 600 /home/$username/.ssh/authorized_keys
    chown -R $username:$username /home/$username/.ssh

		# Allow user to run sudo without a password
    echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$username
}

configure_ssh() {
    # Disable password authentication
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

		# Disable root SSH login
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

    # Restart SSH service to apply changes
    systemctl restart ssh
}

# Create the noditos group & folder
groupadd noditos
mkdir /opt/noditos
chown :noditos /opt/noditos
chmod 2775 /opt/noditos

# SSH public keys for users
SSH_KEY_AX="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEvyG3wCiDEYt3hHyRIb/Uo+UuKcNCksZraKvPwG8FA"
SSH_KEY_JERO="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCci0oRBkDLbW+gpOeC78nBfUXSSLeQ4cHOvyM7RkKfzHy0O0YxQAIjgAqW8CcqeXJPBP2Gf5KNxyQmils/ye+ngPg9s3ij8xoxM+i01I27L6y0od1I3lwK//rUST5s2NFzbbfDr6ZtqmmM495U5LHd4O4YPnNQOgKmT+JTR26uGviZJE8OpCvWK6BrBjdVG1ISCbuJ7XBxrmH45MhHNrpeq/WpZE8JOAj1s+e5t7diKomrzvzo5yGPE4geohU+PoydM+R3tWjGsk8CdA5y1saMp3NqDlEmx+5qrv/AgB5NYwztQ67tOnQppQvoo5ZF2yES9lDou2/4ltn9k49z7LstKFl4UfwRtPhKNM9aL0yuPN6oytHXabMAXFtJ7Se/oZo65nHmtRsnC+nmqUSCC+hS9/TqrZ3Yqf/xpcxcn+9MWv25eNj3MQnaT2i3L1aLNtMZQ0qUj0BYYBag97TxD9m/HwKLiZlHi3pVaKBrHtn/XtD57oKvgtY5OpdmNj0MPZpREnt1gnYoCJLaBvzh+4mqaEUZqmn8RZ65f+i1BXp+T+fTu9ETVcHIJaZrkLt02WmV5t5r2BQyKgwR8458U24PBNEwcJZ7HE6Rn+6pDqqhMcjAbO4AKUukwvKZxRjM+HbL2Sia/gVpo1e6+IrLjqYRLdgtL0MEP2WISpg3z/Ocgw== root@MacBook-Air-de-Jero.local"

# Set up users ax and jero
setup_user "ax" "$SSH_KEY_AX"
setup_user "jero" "$SSH_KEY_JERO"

# Configure SSH to disable password logins
configure_ssh
