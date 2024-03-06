bash
#!/bin/bash

# Set variables
ANSIBLE_PRIVATE_KEY=${SSH_KEY_FILE}

# Configure SSH key on Ansible server
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub ${ANSIBLE_USER}@${REMOTE_HOST}

# Configure SSH key on the remote host
ssh -i ${ANSIBLE_PRIVATE_KEY} ${ANSIBLE_USER}@${REMOTE_HOST} "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub" >> /tmp/authorized_keys
ssh -i ${ANSIBLE_PRIVATE_KEY} ${ANSIBLE_USER}@${REMOTE_HOST} "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat /tmp/authorized_keys >> ~/.ssh/authorized_keys && chmod 644 ~/.ssh/authorized_keys"
ssh -i ${ANSIBLE_PRIVATE_KEY} ${ANSIBLE_USER}@${REMOTE_HOST} "rm -f /tmp/authorized_keys"

# Verify SSH connectivity
ssh -i ${ANSIBLE_PRIVATE_KEY} ${ANSIBLE_USER}@${REMOTE_HOST} "echo 'SSH connection successful'" && echo "SSH connectivity verified"