provider "ovc" {
  server_url = "${var.server_url}"
}

# Definition of the our cloudspace
resource "ovc_cloudspace" "cs" {
  account = "${var.account}"
  name = "${var.cs_name}"
}

# Data definition for every cloudspace
# To be able to get the ip address
#data "ovc_cloudspace" "cs" {
#  account = "${var.account}"
#  name = "${var.cs_name}"
#}

# Definition of the vm to be created with the settings defined in terraform.tfvars
resource "ovc_machine" "kube-mgt" {
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  image_id      = "${var.image_id}"
  size_id       = "${var.size_id}"
  disksize      = "${var.disksize}"
  name          = "kube-mgt"
  description   = "${var.vm_description} - management node"
}

output "kube-mgt" {
  value       = "${ovc_port_forwarding.mgt-ssh.public_ip}"
}

resource "null_resource" "provision-kube-mgt" {

  provisioner "local-exec" {
    command = "ssh-keygen -R [${ovc_port_forwarding.mgt-ssh.public_ip}]:${ovc_port_forwarding.mgt-ssh.public_port}"
  }

  provisioner "local-exec" {
    command = "ssh-keyscan -H -p ${ovc_port_forwarding.mgt-ssh.public_port} ${ovc_port_forwarding.mgt-ssh.public_ip} >> ~/.ssh/known_hosts || true"
  }

  provisioner "file" {
    source      = "scripts"
    destination = "/home/${ovc_machine.kube-mgt.username}/"
  }

  provisioner "remote-exec" {
    inline = [
                        "echo ${ovc_machine.kube-mgt.password} | sudo -S bash /home/${ovc_machine.kube-mgt.username}/scripts/setup-ansible-account.sh",
    ]
  }

  connection {
    type     = "ssh"
    user     = "${ovc_machine.kube-mgt.username}"
    password = "${ovc_machine.kube-mgt.password}"
    host     = "${ovc_port_forwarding.mgt-ssh.public_ip}"
    port     = "${ovc_port_forwarding.mgt-ssh.public_port}"
  }
}

# Master machines
resource "ovc_machine" "k8s-master" {
  count         = "${var.master_count}"
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  image_id      = "${var.image_id}"
  size_id       = "${var.size_id}"
  disksize      = "${var.disksize}"
  name          = "master-${count.index}-${ovc_cloudspace.cs.location}"
  description   = "${var.vm_description} master"
}

resource "null_resource" "provision-k8s-master" {
  count         = "${var.master_count}"

  provisioner "file" {
    source      = "scripts"
    destination = "/home/${ovc_machine.k8s-master.*.username[count.index]}/"
  }

  provisioner "remote-exec" {
    inline = [
			"echo ${ovc_machine.k8s-master.*.password[count.index]} | sudo -S bash /home/${ovc_machine.k8s-master.*.username[count.index]}/scripts/setup-ansible-account.sh",
    ]
  }

  connection {
    type     = "ssh"
    user		 = "${ovc_machine.k8s-master.*.username[count.index]}"
    password = "${ovc_machine.k8s-master.*.password[count.index]}"
    host     = "${ovc_machine.k8s-master.*.ip_address[count.index]}"
    bastion_user     = "${ovc_machine.kube-mgt.username}"
    bastion_password = "${ovc_machine.kube-mgt.password}"
    bastion_host     = "${ovc_port_forwarding.mgt-ssh.public_ip}"
    bastion_port     = "${ovc_port_forwarding.mgt-ssh.public_port}"
  }
}

## Worker machines
resource "ovc_machine" "k8s-worker" {
  count         = "${var.worker_count}"
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  image_id      = "${var.image_id}"
  size_id       = "${var.size_id}"
  disksize      = "${var.disksize}"
  name          = "worker-${count.index}-${ovc_cloudspace.cs.location}"
  description   = "${var.vm_description} node"
}

resource "ovc_disk" "worker-disk" {
  count         = "${var.worker_count}"
  machine_id    = "${ovc_machine.k8s-worker.*.id[count.index]}"
  disk_name     = "data-worker-${count.index}-${ovc_cloudspace.cs.location}"
  description   = "Disk created by terraform"
  size          = 10
  type          = "D"
  ssd_size      = 10
  iops          = 2000
}
#


resource "null_resource" "provision-k8s-worker" {
  count         = "${var.worker_count}"

  # Copy scripts dir to /home/user/
  provisioner "file" {
    source      = "scripts"
    destination = "/home/${ovc_machine.k8s-worker.*.username[count.index]}"
  }

  depends_on = ["ovc_disk.worker-disk"]
  provisioner "remote-exec" {
    inline = [
			"echo ${ovc_machine.k8s-worker.*.password[count.index]} | sudo -S bash /home/${ovc_machine.k8s-worker.*.username[count.index]}/scripts/setup-ansible-account.sh",
			"echo ${ovc_machine.k8s-worker.*.password[count.index]} | sudo -S bash /home/${ovc_machine.k8s-worker.*.username[count.index]}/scripts/move-var.sh",
    ]
  }

  connection {
    type     = "ssh"
    user		 = "${ovc_machine.k8s-worker.*.username[count.index]}"
    password = "${ovc_machine.k8s-worker.*.password[count.index]}"
    host     = "${ovc_machine.k8s-worker.*.ip_address[count.index]}"
    bastion_user     = "${ovc_machine.kube-mgt.username}"
    bastion_password = "${ovc_machine.kube-mgt.password}"
    bastion_host     = "${ovc_port_forwarding.mgt-ssh.public_ip}"
    bastion_port     = "${ovc_port_forwarding.mgt-ssh.public_port}"
  }
}

# Port forwards
resource "ovc_port_forwarding" "mgt-ssh" {
  count = 1
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  public_ip     = "${ovc_cloudspace.cs.external_network_ip}"
  public_port   = 2222
  machine_id    = "${ovc_machine.kube-mgt.id}"
  local_port    = 22
  protocol      = "tcp"
}

resource "ovc_port_forwarding" "k8s-master-api" {
  #count = 1
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  public_ip     = "${ovc_cloudspace.cs.external_network_ip}"
  public_port   = 6443
  machine_id    = "${ovc_machine.k8s-master.*.id[0]}"
  local_port    = 6443
  protocol      = "tcp"
}

resource "ovc_port_forwarding" "k8s-worker-0-http" {
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  public_ip     = "${ovc_cloudspace.cs.external_network_ip}"
  public_port   = 80
  machine_id    = "${ovc_machine.k8s-worker.*.id[0]}"
  local_port    = 31080
  protocol      = "tcp"
}

resource "ovc_port_forwarding" "k8s-worker-0-https" {
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  public_ip     = "${ovc_cloudspace.cs.external_network_ip}"
  public_port   = 443
  machine_id    = "${ovc_machine.k8s-worker.*.id[0]}"
  local_port    = 31443
  protocol      = "tcp"
}

# Ansible hosts be
resource "ansible_host" "kube-mgt" {
    inventory_hostname = "${ovc_machine.kube-mgt.name}"
    groups = ["mgt"]
    vars {
        ansible_user = "ansible"
        ansible_host = "${ovc_port_forwarding.mgt-ssh.public_ip}"
        ansible_port = "${ovc_port_forwarding.mgt-ssh.public_port}"
#        ansible_user = "${ovc_machine.kube-mgt.username}"
#        ansible_ssh_pass = "${ovc_machine.kube-mgt.password}"
#        ansible_become_pass = "${ovc_machine.kube-mgt.password}"
        ansible_python_interpreter = "/usr/bin/python3"
    }
}

resource "ansible_host" "kube-master" {
    count = "${var.master_count}"
    inventory_hostname = "${ovc_machine.k8s-master.*.name[count.index]}"
    groups = ["kube-master","etcd","k8s-cluster","k8s-cluster"]
    vars {
        ansible_user = "ansible"
        ansible_host = "${ovc_machine.k8s-master.*.ip_address[count.index]}"
#        ansible_user = "${ovc_machine.k8s-master.*.username[count.index]}"
#        ansible_ssh_pass = "${ovc_machine.k8s-master.*.password[count.index]}"
#        ansible_become_pass = "${ovc_machine.k8s-master.*.password[count.index]}"
        ansible_python_interpreter = "/usr/bin/python3"
    }
}

resource "ansible_host" "kube-worker" {
    count = "${var.worker_count}"
    groups = ["kube-node","k8s-cluster","k8s-cluster"]
    inventory_hostname = "${ovc_machine.k8s-worker.*.name[count.index]}"
    vars {
        ansible_user = "ansible"
        ansible_host = "${ovc_machine.k8s-worker.*.ip_address[count.index]}"
#        ansible_user = "${ovc_machine.k8s-worker.*.username[count.index]}"
#        ansible_ssh_pass = "${ovc_machine.k8s-worker.*.password[count.index]}"
#        ansible_become_pass = "${ovc_machine.k8s-worker.*.password[count.index]}"
        ansible_python_interpreter = "/usr/bin/python3"
    }
}

#resource "ansible_group" "calico-rr" {
#  inventory_group_name = "calico-rr"
#}

resource "ansible_group" "k8s-cluster" {
  inventory_group_name = "k8s-cluster"
  vars {
    ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand='ssh -W %h:%p -p ${ovc_port_forwarding.mgt-ssh.public_port} -q ansible@${ovc_port_forwarding.mgt-ssh.public_ip}'"
  }
}
