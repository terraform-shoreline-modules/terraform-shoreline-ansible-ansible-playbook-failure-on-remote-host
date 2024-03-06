#!/bin/bash
SSH_PORT=${SSH_PORT}

# Check if the SSH port is open on the remote host
nc -zv $REMOTE_HOST $SSH_PORT

if [ $? -ne 0 ]; then
    # If the SSH port is not open, open it on the firewall
    firewall-cmd --zone=public --permanent --add-port=$SSH_PORT/tcp
    firewall-cmd --reload
    echo "SSH port $SSH_PORT opened on firewall for $REMOTE_HOST"
else
    echo "SSH port $SSH_PORT is already open on $REMOTE_HOST"
fi