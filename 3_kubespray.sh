#!/bin/bash

ansible-playbook -i provisioning/inventory/demo kubespray/cluster.yml -v -b
