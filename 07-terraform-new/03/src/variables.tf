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
  default     = "ru-central1-d"
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

variable "vm_platform_id" {
  type        = string
  default     = "standard-v2"
  description = "VPC network&subnet name"
}

locals {
  ssh_metadata = "${"ubuntu"}:${file("./.ssh/ed25519.pub")}"
}

variable "vm_resources" {
  type = list(object({
    name = string
    cores     = number
    core_fraction = number
    ram     = number
    disk    = number
    platform_id = string
  }))
  default = [
    {
      name = "main"
      cores     = 2
      core_fraction = 5
      ram     = 2
      disk    = 5
      platform_id = "standard-v2"
    },
    {
      name = "replica"
      cores     = 2
      core_fraction = 20
      ram     = 2
      disk    = 10
      platform_id = "standard-v3"
    },
  ]
}