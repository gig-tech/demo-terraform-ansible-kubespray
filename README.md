# Demo of Terraform, Ansible and Kubespray integration

With the code in this repository you can deploy kubernetes cluster on top of GIG Edge Cloud

This consists of
* terraform configuration to manage the cloudspaces and create the virtual machines
* ansible configuration for the virtual machines
* kubespray configuration to deploy the kubernetes cluster
* ansible playbook to install persistent volume for the kubernetes cluster

** ansible ( >= 2.8.0) [ansible installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Using this repository

Import submodule:

```
git config --global status.submoduleSummary true
git submodule init
git submodule update
```

Requirements:
- Itsyou.online account (retrieve a client ID and client secret and get a JWT) (https://github.com/gig-tech/terraform-provider-ovc#authentication)
- Necessary permissions on a G8 (cloudspace account), that is linked to your Itsyou.online account
- Edit terraform/terraform.tfvars as needed (may need to update `account` and `server_url`)
- The terraform-inventory script: https://github.com/nbering/terraform-inventory/ , already provided in the repo
- The ansible provider plugin https://github.com/nbering/terraform-provider-ansible , download the latest release and put the file at ~/.terraform.d/plugins/terraform-provider-ansible
- The OVC provider plugin https://github.com/gig-tech/terraform-provider-ovc, download the latest release and put the file at ~/.terraform.d/plugins/terraform-provider-ovc
- Your ssh public key will be added when deploying with Terraform

Before starting update Terraform configuration in `config.env` file with your own data. You can also add Terraform variables to `terraform/terraform.tfvars`. It is important that `server_url`, `client_jwt` and `account` are given as environmental variables, as they are used in further steps.

### Provision with terraform

Run `./1_terraform-provision.sh`

### Provision with kubespray

Run `./2_kubespray.sh`

### Install OVC SCI driver on the Kubernetes cluster

Run `./3_sci_driver.sh`

### Tear down everything

Run `./9_destroy.sh`
