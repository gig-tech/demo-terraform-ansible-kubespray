#!/bin/sh

ansible-playbook -i inventory/terraform.py  ovc-disk-csi-driver/install-ovc-csi-driver.yml
