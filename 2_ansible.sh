#/bin/sh

ANSIBLE_TF_DIR=terraform/ python provisioning/inventory/terraform.py > provisioning/inventory/demo.json
ansible-playbook -i provisioning/inventory/demo  provisioning/provision-k8s-nodes.yml
