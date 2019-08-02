#!/bin/bash

ansible-playbook -i terraform-inventory/terraform.py kubespray/cluster.yml -v -b

