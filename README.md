# Demo of terraform, ansible and kubespray integration

With the code in this repository you can meneja the meneja infrastructure

This consists of
* terraform configuration to manage the cloudspaces and create the virtual machines
* ansible configuration to configure the virtual machines
* kubespray configuration to deploy the kubernetes cluster

 - ansible ( >= 2.8.0) [ansible installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

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
- Your ssh public key will be added during provisioning, add it to `terraform/scripts/setup-ansible-account.sh`

Before starting you must make `terraform/iyo.env` and add your IYO client_jwt.  
This file is in the gitignore file, so it will not be commited to the repo by accident.
The env file will be sourced by `./1_terraform-provision.sh`.

Set up your IYO environment variables:
```
$ cp terraform/iyo.env.example terraform/iyo.env
$ vi terraform/iyo.env
```

### Provision with terraform

Run `./1_terraform-provision.sh`

### Provision with ansible

Run `./2_ansible.sh`

If you receive the following error:  
`The ipaddr filter requires python's netaddr be installed on the ansible controller`  
You may need to install the `ipaddr` library using your package manager:  
`apt-get install python-ipadddr` (if ansible uses python 3.x install `python3-ipaddr`)

### Provision with kubespray

Run `./3_kubespray.sh`

### Tear down everything

Run `./9_destroy.sh`
