#!/bin/bash

# Create ansuble account
useradd -m -s /bin/bash ansible

# Configure password less sudo
echo "ansible    ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/90-ansible

# Configure ssh keys for initial provisioning
# Add your own and commit it to the repo
chmod 700 /home/ansible/
mkdir /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
echo $pub_rsa >> /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
