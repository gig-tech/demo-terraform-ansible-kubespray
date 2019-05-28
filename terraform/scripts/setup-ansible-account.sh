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
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaF1RUpbXjgQwZsnBJxRX2rP6tSiLEgkCoEW+d7PhGD3NhAXrYSOmX9fxvU7+YnE8r7NnNOccAL+l5ISEvlaBh2EkckcxMpin8xyFx/Xfa3noSPx5n9oa+J/6TL1/TqgpX5Y+Ie2bOA7DWuWwWeRNFX5qgn5152nCcq9N5wt3+6Js415xArYhbFqL6yiNXzRE0rqoVp+lq9reJ0DlcTRxAQpAdCtirYr7a3u2wNDdr/67QrWjB2cdYukgfR4tSVU8aDJ04ruY7qM2djvF1CSkqzrxDRboG94zj/nDFozhc5+zDXLt41G6kvpLm1jN3QfCqi6j3lblTz8x0UHEZitRb" >> /home/ansible/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaF1RUpbXjgQwZsnBJxRX2rP6tSiLEgkCoEW+d7PhGD3NhAXrYSOmX9fxvU7+YnE8r7NnNOccAL+l5ISEvlaBh2EkckcxMpin8xyFx/Xfa3noSPx5n9oa+J/6TL1/TqgpX5Y+Ie2bOA7DWuWwWeRNFX5qgn5152nCcq9N5wt3+6Js415xArYhbFqL6yiNXzRE0rqoVp+lq9reJ0DlcTRxAQpAdCtirYr7a3u2wNDdr/67QrWjB2cdYukgfR4tSVU8aDJ04ruY7qM2djvF1CSkqzrxDRboG94zj/nDFozhc5+zDXLt41G6kvpLm1jN3QfCqi6j3lblTz8x0UHEZitRb" >> /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
