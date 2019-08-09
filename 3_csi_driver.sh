#!/bin/sh

ansible-playbook -i inventory/terraform.py  install-csi-driver/install-ovc-csi-driver.yml
