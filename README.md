
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Ansible Playbook Failure on Remote Host
---

This incident type refers to a problem encountered while attempting to run an Ansible playbook on a remote host. The issue may be related to SSH or inventory problems. This can result in the playbook not being executed properly, leading to potential failures or errors. Troubleshooting is required to identify and resolve the root cause of the issue.

### Parameters

```shell
export REMOTE_HOST="PLACEHOLDER"
export SSH_KEY_FILE="PLACEHOLDER"
export INVENTORY_FILE_PATH="PLACEHOLDER"
export PLAYBOOK_FILE_PATH="PLACEHOLDER"
export ANSIBLE_USER="PLACEHOLDER"
export SSH_PORT="PLACEHOLDER"
```

## Debug

### Check if remote host is reachable

```shell
ping ${REMOTE_HOST}
```

### Check if the ssh key is added to the ssh-agent

```shell
ssh-add -l
```

### Check if the ssh key is authorized on the remote host

```shell
ssh -i ${SSH_KEY_FILE} ${ANSIBLE_USER}@${REMOTE_HOST} "echo 'Authorized'"
```

### Check if the ssh key has correct permissions

```shell
stat ${SSH_KEY_FILE}
```

### Check if ssh connection can be established

```shell
ssh -vvv ${ANSIBLE_USER}@${REMOTE_HOST}
```

### Check if ansible is installed and its version

```shell
ansible --version
```

### Check if the Ansible user has the necessary permissions on the remote host

```shell
ansible ${REMOTE_HOST} -m command -a "sudo -l -U ansible"
```

### Check if the inventory file exists

```shell
if [ -f ${INVENTORY_FILE_PATH} ]; then echo "File exists"; else echo "File does not exist"; fi
```

### Check if the playbook runs successfully on the localhost

```shell
ansible-playbook ${PLAYBOOK_FILE_PATH} -i ${INVENTORY_FILE_PATH} --limit localhost
```

### The Ansible playbook may have syntax errors or incorrect configuration that is not compatible with the remote host.

```shell
#!/bin/bash

# set the path to the Ansible playbook file
playbook_path=${PLAYBOOK_FILE_PATH}

# run the playbook in check mode to identify syntax errors
ansible-playbook -i ${INVENTORY_FILE_PATH} $playbook_path --syntax-check

# if syntax check fails, display the error message and exit
if [ $? -ne 0 ]; then
    echo "ERROR: Syntax check failed for playbook $playbook_path"
    exit 1
fi

# if syntax check passes, run the playbook in verbose mode to identify any other issues
ansible-playbook -i ${INVENTORY_FILE_PATH} $playbook_path -vvv

# display a message indicating that the playbook ran successfully
echo "Playbook $playbook_path ran successfully"
```

## Repair

### Open the ssh port if not open on the firewall of the remote host

```shell
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
```

### Ensure that the SSH key is configured correctly on the remote host and on the Ansible server

```shell
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
```