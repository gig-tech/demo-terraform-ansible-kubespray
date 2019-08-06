provider "ovc" {
  server_url = "${var.server_url}"
  client_jwt = "${var.client_jwt}"
}
# Definition of the cloudspace
resource "ovc_cloudspace" "cs" {
  account = "${var.account}"
  name = "${var.cs_name}"
}
data "ovc_image" "image" {
  most_recent = true
  name_regex  = "${var.image_name}"
}
# Definition of the vm to be created with the settings defined in terraform.tfvars
resource "ovc_machine" "kube-mgt" {
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  image_id      = "${data.ovc_image.image.image_id}"
  memory        = "${var.memory}"
  vcpus         = "${var.vcpus}"
  disksize      = "${var.disksize}"
  name          = "${var.cs_name}-terraform-kube-mgt"
  description   = "${var.vm_description} - management node"
  userdata      = "users: [{name: ansible, shell: /bin/bash, ssh-authorized-keys: [${var.ssh_key}]}]"
}
output "kube-mgt" {
  value       = "${ovc_port_forwarding.mgt-ssh.public_ip}"
}

# Master machines
resource "ovc_machine" "k8s-master" {
  count         = "${var.master_count}"
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  image_id      = "${data.ovc_image.image.image_id}"
  memory        = "${var.memory}"
  vcpus         = "${var.vcpus}"
  disksize      = "${var.disksize}"
  name          = "master-${count.index}-${ovc_cloudspace.cs.location}"
  description   = "${var.vm_description} master"
  userdata      = "users: [{name: ansible, shell: /bin/bash, ssh-authorized-keys: [${var.ssh_key}]}, {name: root, shell: /bin/bash, ssh-authorized-keys: [${var.ssh_key}]}]"
}
# configure user access on master nodes
resource "null_resource" "provision-k8s-master" {
  count         = "${var.master_count}"
  triggers {
      build_number = "${timestamp()}"
  }
  provisioner "file" {
    content      = "ansible    ALL=(ALL:ALL) NOPASSWD: ALL"
    destination = "/etc/sudoers.d/90-ansible"
  }
  connection {
    type     = "ssh"
    user		 = "root"
    host     = "${ovc_machine.k8s-master.*.ip_address[count.index]}"
    bastion_user     = "ansible"
    bastion_host     = "${ovc_port_forwarding.mgt-ssh.public_ip}"
    bastion_port     = "${ovc_port_forwarding.mgt-ssh.public_port}"
  }
}
## Worker machines
resource "ovc_machine" "k8s-worker" {
  count         = "${var.worker_count}"
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  image_id      = "${data.ovc_image.image.image_id}"
  memory        = "${var.memory}"
  vcpus         = "${var.vcpus}"
  disksize      = "${var.disksize}"
  name          = "worker-${count.index}-${ovc_cloudspace.cs.location}"
  description   = "${var.vm_description} node"
  userdata      = "users: [{name: ansible, shell: /bin/bash, ssh-authorized-keys: [${var.ssh_key}]}, {name: root, shell: /bin/bash, ssh-authorized-keys: [${var.ssh_key}]}]"
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
# Port forwards
resource "ovc_port_forwarding" "k8s-master-api" {
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
resource "ovc_port_forwarding" "mgt-ssh" {
  count = 1
  cloudspace_id = "${ovc_cloudspace.cs.id}"
  public_ip     = "${ovc_cloudspace.cs.external_network_ip}"
  public_port   = 2222
  machine_id    = "${ovc_machine.kube-mgt.id}"
  local_port    = 22
  protocol      = "tcp"
}
resource "null_resource" "provision-k8s-worker" {
  count         = "${var.worker_count}"
  triggers {
      build_number = "${timestamp()}"
  }
  # configure access for ansible user
  provisioner "file" {
    content      = "ansible    ALL=(ALL:ALL) NOPASSWD: ALL"
    destination = "/etc/sudoers.d/90-ansible"
  }
  # Copy scripts dir to /home/user/
  provisioner "file" {
    source      = "scripts"
    destination = "/home/${ovc_machine.k8s-worker.*.username[count.index]}"
  }
  depends_on = ["ovc_disk.worker-disk"]
  provisioner "remote-exec" {
    inline = [
			"echo ${ovc_machine.k8s-worker.*.password[count.index]} | sudo -S bash /home/${ovc_machine.k8s-worker.*.username[count.index]}/scripts/move-var.sh",
    ]
  }
  connection {
    type     = "ssh"
    user		 = "root"
    host     = "${ovc_machine.k8s-worker.*.ip_address[count.index]}"
    bastion_user     = "ansible"
    bastion_host     = "${ovc_port_forwarding.mgt-ssh.public_ip}"
    bastion_port     = "${ovc_port_forwarding.mgt-ssh.public_port}"
  }
}

# Ansible hosts
resource "ansible_host" "kube-mgt" {
    inventory_hostname = "${ovc_machine.kube-mgt.name}"
    groups = ["mgt"]
    vars {
        ansible_user = "ansible"
        ansible_host = "${ovc_port_forwarding.mgt-ssh.public_ip}"
        ansible_port = "${ovc_port_forwarding.mgt-ssh.public_port}"
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
        ansible_python_interpreter = "/usr/bin/python3"
    }
}
resource "ansible_group" "k8s-cluster" {
  inventory_group_name = "k8s-cluster"
  vars {
    ansible_ssh_common_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand='ssh -W %h:%p -p ${ovc_port_forwarding.mgt-ssh.public_port} -q ansible@${ovc_port_forwarding.mgt-ssh.public_ip}'"
  }
}
