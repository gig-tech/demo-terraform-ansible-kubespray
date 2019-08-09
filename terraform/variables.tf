variable "client_jwt" {
  description = "Client jwt created on itsyou.online with client id and secret"
}
variable "server_url" {
  description = "API server URL"
}
variable "account" {
  description = "Account name"
}
variable "cloudspace" {
  description = "Cloudspace name"
  default = "demo"
}
variable "vm_description" {
  description = "Description of the VM"
  default = "kubernester cluster"
}
variable "memory" {
  description = "Machine memory"
  default     = "2048"
}
variable "vcpus" {
  description = "Number of machine CPUs"
  default     = "2"
}
variable "disksize" {
  description = "disksize"
  default     = "20"
}
variable "image_name" {
  description = "Image name or regular expression"
  default     = "(?i).*\\.?ubuntu.*16"
}
variable "master_count" {
  description = "Number of master nodes"
}
variable "worker_count" {
  description = "Number of worker nodes"
}
variable "ssh_key" {
  description = "Public SSH key that will be loaded to the machines"
}
