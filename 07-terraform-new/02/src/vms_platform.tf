#=== Common variables

variable "vms_resources" {
  description = "Common resource parameters"
  type        = map(map(number))
  default     = {
    vm_web_resources = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
    vm_db_resources = {
      cores         = 2
      memory        = 1
      core_fraction = 5
    }
  }
}

variable "generic_metadata" {
  description = "Generic metadata"
  type        = map(string)
  default     = {
    serial-port-enable = "1"
    ssh-keys          = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBYAbng9Yef+LiKnjdi/9kSNhN2Nwvtrqf85GwWNVvgNoZbASh4BL5UEUBCZ61BDR7pPGjg+uNrzdCqjzU23ZKL7BIsmt2kALpaUM8d33UOS5URaVCrM7JHNKGHWxBK4ADbKC4A9FzuYGzu6VOp8muaXE44P99WMu3gqrTvNLcvtO7kk3/gbrHHliFV934A1XmVF6wsatb3KNez1F4bii6PviuFvDZj8x2Y5PBVuwJZzg5ZnTGQN6b8xhhLQLI/C4FWpq7Vqjj093YHmtYuN3VpNP4wOG1BXff6MWFskXNn+Ro3FIcO8ziB1NwHJRcYbOE6fhIz6BtxH/a7kqE9Vwb root"
  }
}

#=== Web VM variables

variable "vm_web_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "YC Image"
}

variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
  description = "VM Name"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "Type of VM virtual hardware"
}

/*
variable "vm_web_cores" {
  type        = number
  default     = 2
  description = "Amount of CPU cores for the VM"
}

variable "vm_web_memory" {
  type        = number
  default     = 1
  description = "RAM capacity"
}

variable "vm_web_core_fraction" {
  type        = number
  default     = 5
  description = "Percent of CPU load allowed"
}
*/

variable "vm_web_preemptible" {
  type        = bool
  default     = true
  description = "Is it interruptable type of VM?"
}

variable "vm_web_nat" {
  type        = bool
  default     = true
  description = "Shall provision NAT?"
}

variable "vm_web_serial_port_enable" {
  type        = number
  default     = 1
  description = "Shall enable serial console for the VM?"
}

#=== DB VM variables

variable "vm_db_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "YC Image"
}

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "VM Name"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v1"
  description = "Type of VM virtual hardware"
}

/*
variable "vm_db_cores" {
  type        = number
  default     = 2
  description = "Amount of CPU cores for the VM"
}

variable "vm_db_memory" {
  type        = number
  default     = 2
  description = "RAM capacity"
}

variable "vm_db_core_fraction" {
  type        = number
  default     = 20
  description = "Percent of CPU load allowed"
}
*/

variable "vm_db_preemptible" {
  type        = bool
  default     = true
  description = "Is it interruptable type of VM?"
}

variable "vm_db_nat" {
  type        = bool
  default     = true
  description = "Shall provision NAT?"
}

variable "vm_db_serial_port_enable" {
  type        = number
  default     = 1
  description = "Shall enable serial console for the VM?"
}

/*
#=== SSH variables

variable "vms_ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "User part of metadata for SSH public key"
}

variable "vms_ssh_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBYAbng9Yef+LiKnjdi/9kSNhN2Nwvtrqf85GwWNVvgNoZbASh4BL5UEUBCZ61BDR7pPGjg+uNrzdCqjzU23ZKL7BIsmt2kALpaUM8d33UOS5URaVCrM7JHNKGHWxBK4ADbKC4A9FzuYGzu6VOp8muaXE44P99WMu3gqrTvNLcvtO7kk3/gbrHHliFV934A1XmVF6wsatb3KNez1F4bii6PviuFvDZj8x2Y5PBVuwJZzg5ZnTGQN6b8xhhLQLI/C4FWpq7Vqjj093YHmtYuN3VpNP4wOG1BXff6MWFskXNn+Ro3FIcO8ziB1NwHJRcYbOE6fhIz6BtxH/a7kqE9Vwb root"
  description = "ssh-keygen -t rsa2048"
}
*/