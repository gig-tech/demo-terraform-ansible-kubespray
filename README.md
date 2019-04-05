# Demo of terraform, ansible and kubespray integration

With the code in this repository you can meneja the meneja infrastructure

This consists of
* terraform configuration to manage the cloudspaces and create the virtual machines
* ansible configuration to configure the virtual machines
* kubespray configuration to deploy the kubernetes cluster

 - ansible ( > 2.7.5) https://www.ansible.org

## Using this repository

Set up submodule status:

```
git config --global status.submoduleSummary true
```

Requirements:
- Itsyou.online account
- necessary permissions on a G8 (cloudspace account), that is linked to your Itsyou.online account
- The terraform-inventory script: https://github.com/nbering/terraform-inventory/ , provided in the repo
- The ansible provider plugin https://github.com/nbering/terraform-provider-ansible , download the latest release and put the file at ~/.terraform.d/plugins/terraform-provider-ansibl
- Your ssh public key will be added during provisioning, add it to `terraform/scripts/setup-ansible-account.sh`

Before starting you must make `terraform/iyo.env` and add your IYO client_id and client_secret. Get it at
https://itsyou.online/#/settings . This file is in the gitignore file, so it will not be commited to the repo by accident.
Then you source the env file.

Set up your IYO environment variables:
```
$ cp terraform/iyo.env.example terraform/iyo.env
$ vi terraform/iyo.env
```

### Provision with terraform

Run `./1_terraform-provision.sh`

### Provision with ansible

Run `./2_ansible.sh`

### Provision with kubespray

Run `./3_kubespray.sh`

### Tear down everything

Run `./9_destroy.sh`


