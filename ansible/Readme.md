# Maxout Deployment with Ansible

This project automates the deployment of Maxout using Ansible. The playbook handles the setup and configuration of various components such as web ingress, SQL server, and Nomad across multiple nodes.

## Prerequisites

- Ansible installed on the control machine.
- SSH access to all target nodes.
- A configuration file (`config.yml`) containing necessary variables and node definitions.

## Deployment


Follow this for installing ansible: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip

To deploy Maxout, execute the following command:
```bash

ansible-playbook playbooks/test_deploy.yml --extra-vars "config_path=/path/to/your/config.yml

# To cleanup a deployment, execute the following command

ansible-playbook playbooks/test_cleanup.yml --extra-vars "config_path=/path/to/your/config.yml

```
