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
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCS6NlfuxLNHco+Hs/gEyw0cElnctKNz00hpU7xhw4jzr/BKtD0JoUYatIsj4PfXLiQAay99twJHfbYM0o2uDjtLQE5hFBHzI2bq4CeJBfg8XZ/dbhpRQOYitKzT03wvHEeUNUcW5D11OSk9aVjdsljyTeBUOhrGZIrv/9HS5LATry7YuD9Or4ro5kwo5yIqcPW27NOC3BIn3kLIUoDUb9xmHX2dpFXOa5yvuliAeFfqI3Ef/3V7z5ZHC6YvmT3kRb2Xw/YQXtMLFzHyl+lyHfBGjTUbqCJFmXdYsZs4DVvXjrhKZ084lln9eGIjQyYYekmhvEMbKayxPZ3BVaG9M0n rgevaert@MacBook-Air.home.greenitglobe.com" >> /home/ansible/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7mv2VuPAvD6H6k1g2tPW7bDK6RskjRrNZtLowzSjA2TjOrOo4kCG/g3dPdBqQTr4+ksJDaaj1A03sPtZo1N1WBDSGZ2BREynPoSRFvQ2qve3LVe45Aosg08e27iehlC0pmLpq0uDWh3I0hrGZNC6NH7oBUsC3Hy37GL/VEsZieHjcGEmUDBuw5ZKeIzVZv0gBqL/zocaXtUFrx1uuNsKkPQaBHaHrQZdwsIPLR5CsQFyFdPzze0SrqSgN7A7jKpDOxf0sVVAlJthqTgxgzKOJC4zsrxte0AYD77EiSE8LiAj6/ENaMzjxdxoTdQ42BHRGo3S1Ll39eMit2E5fDSKz gitlab-meneja" >> /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
