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
- Have Terraform v0.11.x installed as 0.12 is not supported by the [OVC Terraform provider](https://github.com/gig-tech/terraform-provider-ovc/issues/48)  
Version 0.11.14 binary files can be found here: https://releases.hashicorp.com/terraform/0.11.14/
- Have [Ansible installed](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Itsyou.online account (retrieve a client ID and client secret and get a JWT) (https://github.com/gig-tech/terraform-provider-ovc#authentication)
- Necessary permissions on a G8 (cloudspace account), that is linked to your Itsyou.online account
- Edit terraform/terraform.tfvars as needed (may need to update `account` and `server_url`)
- The terraform-inventory script: https://github.com/nbering/terraform-inventory/ , already provided in the repo
- The ansible provider plugin https://github.com/nbering/terraform-provider-ansible , download the latest release and put the file at ~/.terraform.d/plugins/terraform-provider-ansible
- The OVC provider plugin https://github.com/gig-tech/terraform-provider-ovc, download the latest release and put the file at ~/.terraform.d/plugins/terraform-provider-ovc
- Your ssh public key will be added when deploying with Terraform

Before starting rename (for example into `config.env`) and update configuration file `config.env.example` with your own data. Export environment variables

``` shell
. config.env
```

Terraform supports setting variables with environment variables or in `terraform.tfvar` file. When setting as environmentals, variables should be prefixed with `TF_VAR_`.
For this example it is important that `server_url`, `client_jwt` and `account` are given as environmental variables, as they are used in further steps. You can also add values for other Terraform variables defined in `terraform/variables.tf` to `terraform/terraform.tfvars` or to `config.env`.

Note that ANSIBLE_TF_DIR variable in `config.env` should contain path to the Terraform configuration directory (in this example `terraform` is the relative path in the project folder). This is necessary for dynamic inventory to work with the Ansible playbooks.

### Provision with terraform

Run `./1_terraform-provision.sh`

### Install the Kubernetes cluster with kubespray

Run `./2_kubespray.sh`

If you receive the following error:  
`The ipaddr filter requires python's netaddr be installed on the ansible controller`  
You may need to install the `netaddr` library:  
`apt-get install python-netaddr`

### Install OVC SCI driver on the Kubernetes cluster

Run `./3_sci_driver.sh`

### Tear down everything

Run `./9_destroy.sh`
