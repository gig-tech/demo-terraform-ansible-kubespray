#!/bin/sh

ansible-playbook -i inventory/terraform.py  ovc-disk-csi-driver/add-persistent-volume.yml
