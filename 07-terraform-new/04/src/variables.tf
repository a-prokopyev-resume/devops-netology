###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

###common vars

###example vm_web var
variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "example vm_web_ prefix"
}

###example vm_db var
variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "example vm_db_ prefix"
}

variable "vm_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "YC disk image name"
}

variable "ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "ssh-keygen -t ed25519"
}

locals {
  ssh_user="ubuntu"
  ssh_public_key = "${file(".ssh/ed25519.pub")}"
}


locals { 
  # Datacenter information
  datacenter_info  =  {
    token=var.token
    cloud_id=var.cloud_id
    folder_id=var.folder_id
    default_zone=var.default_zone
  }
}
