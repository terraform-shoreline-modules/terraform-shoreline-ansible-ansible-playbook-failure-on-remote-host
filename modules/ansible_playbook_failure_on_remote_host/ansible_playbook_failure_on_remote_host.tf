resource "shoreline_notebook" "ansible_playbook_failure_on_remote_host" {
  name       = "ansible_playbook_failure_on_remote_host"
  data       = file("${path.module}/data/ansible_playbook_failure_on_remote_host.json")
  depends_on = [shoreline_action.invoke_ansible_syntax_check,shoreline_action.invoke_ssh_port_firewall_mgmt,shoreline_action.invoke_configure_ssh_keys]
}

resource "shoreline_file" "ansible_syntax_check" {
  name             = "ansible_syntax_check"
  input_file       = "${path.module}/data/ansible_syntax_check.sh"
  md5              = filemd5("${path.module}/data/ansible_syntax_check.sh")
  description      = "The Ansible playbook may have syntax errors or incorrect configuration that is not compatible with the remote host."
  destination_path = "/tmp/ansible_syntax_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "ssh_port_firewall_mgmt" {
  name             = "ssh_port_firewall_mgmt"
  input_file       = "${path.module}/data/ssh_port_firewall_mgmt.sh"
  md5              = filemd5("${path.module}/data/ssh_port_firewall_mgmt.sh")
  description      = "Open the ssh port if not open on the firewall of the remote host"
  destination_path = "/tmp/ssh_port_firewall_mgmt.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "configure_ssh_keys" {
  name             = "configure_ssh_keys"
  input_file       = "${path.module}/data/configure_ssh_keys.sh"
  md5              = filemd5("${path.module}/data/configure_ssh_keys.sh")
  description      = "Ensure that the SSH key is configured correctly on the remote host and on the Ansible server"
  destination_path = "/tmp/configure_ssh_keys.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_ansible_syntax_check" {
  name        = "invoke_ansible_syntax_check"
  description = "The Ansible playbook may have syntax errors or incorrect configuration that is not compatible with the remote host."
  command     = "`chmod +x /tmp/ansible_syntax_check.sh && /tmp/ansible_syntax_check.sh`"
  params      = ["PLAYBOOK_FILE_PATH","INVENTORY_FILE_PATH"]
  file_deps   = ["ansible_syntax_check"]
  enabled     = true
  depends_on  = [shoreline_file.ansible_syntax_check]
}

resource "shoreline_action" "invoke_ssh_port_firewall_mgmt" {
  name        = "invoke_ssh_port_firewall_mgmt"
  description = "Open the ssh port if not open on the firewall of the remote host"
  command     = "`chmod +x /tmp/ssh_port_firewall_mgmt.sh && /tmp/ssh_port_firewall_mgmt.sh`"
  params      = ["SSH_PORT","REMOTE_HOST"]
  file_deps   = ["ssh_port_firewall_mgmt"]
  enabled     = true
  depends_on  = [shoreline_file.ssh_port_firewall_mgmt]
}

resource "shoreline_action" "invoke_configure_ssh_keys" {
  name        = "invoke_configure_ssh_keys"
  description = "Ensure that the SSH key is configured correctly on the remote host and on the Ansible server"
  command     = "`chmod +x /tmp/configure_ssh_keys.sh && /tmp/configure_ssh_keys.sh`"
  params      = ["SSH_KEY_FILE","ANSIBLE_USER","REMOTE_HOST"]
  file_deps   = ["configure_ssh_keys"]
  enabled     = true
  depends_on  = [shoreline_file.configure_ssh_keys]
}

