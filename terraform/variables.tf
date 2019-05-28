variable "client_jwt" {
  description = "Client jwt created on itsyou.online with client id and secret"
}

variable "server_url" {
  description = "API server URL"
}

variable "account" {
  description = "account"
}

variable "cs_name" {
  description = "cloudspace name"
}

variable "vm_description" {
  description = "Description of the VM"
}

variable "image_id" {
  description = "Image_id"
  default     = "1"
}

variable "size_id" {
  description = "size_id"
  default     = "3"
}

variable "disksize" {
  description = "disksize"
  default     = "20"
}

variable "master_count" {
  description = "Number of master nodes"
}

variable "worker_count" {
  description = "Number of worker nodes"
}
