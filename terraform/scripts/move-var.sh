#!/bin/bash

set -e

# This script will move the data of the /var directory
# to the partion /dev/vdb. The system is rebooted
#
# First we wait till the disk becomes available
# It will first make a ext4 filesystem on it, move the data
# with rsync and then set up /etc/fstab

until [ -b /dev/vdb ]
do
     echo /dev/vdb not ready
     sleep 5
done

if ! mount | grep vdb
  then
     mkfs.ext4 /dev/vdb

     mount /dev/vdb /mnt
     rsync -aqxP /var/* /mnt
     umount /mnt
     uuid=`lsblk /dev/vdb -o UUID -n`
     echo UUID=$uuid /var ext4 defaults 0 0 >> /etc/fstab

     # Reboot after one minute, this lets the terraform remote-exec
     # provisioner exit nicely
     shutdown -r
fi

