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