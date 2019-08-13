#!/bin/sh

ansible-playbook -i terraform-inventory/terraform.py  install-csi-driver/install-ovc-csi-driver.yml
