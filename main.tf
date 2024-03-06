terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "ansible_playbook_failure_on_remote_host" {
  source    = "./modules/ansible_playbook_failure_on_remote_host"

  providers = {
    shoreline = shoreline
  }
}