#=============================================== The Beginning of the Copyright Notice ===================================================
# The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.
# Contact of the AUTHOR: a.prokopyev.resume at gmail dot com
# WWW: https://github.com/a-prokopyev-resume/devops-netology
#
# All source code and other content contained in this file is protected by copyright law.
# This file is licensed by the AUTHOR under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
#
# THIS FILE IS LICENSED ONLY PROVIDED FOLLOWING RESTRICTIONS ALSO APPLY:
# Nobody except the AUTHOR may alter or remove this copyright notice from any copies of this file content (including modified fragments).
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
#
# ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or 
# if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or licensee  
# is STRONGLY PROHIBITED to use this file by any method.
#================================================== The End of the Copyright Notice ======================================================

variable "subnet" {
  type        = object({
	id            = string
	network_id    = string
  })
}

variable "name" {
  type        = string
}

variable "int_ifaces" {
  type        =  list(string)
}

variable "ext_ifaces" {
  type        =  list(bool)
}

variable "images" {
  type	      = list(string)
}

data "yandex_iam_service_account" "tf_backend" {
  name = "tf-backend"
}

#data "yandex_compute_image" "list" {
#  for_each = toset(var.images)
#  family  = each.value

#  family = [for image in var.images : image]

#  for_each = { for image in var.images : image => image }
#  family   = each.value
#}

data "template_file" "cloudinit" {
  template = file("cloud-init.yml")
  vars = {
    ssh_user = local.vm_config.ssh.user
    ssh_public_key = local.vm_config.ssh.public_key
  }
}

# =====> Compute instances:

resource "yandex_compute_instance" "this" {
  count = length(var.int_ifaces)

  name = "${var.name}-${count.index+1}"

  folder_id = local.datacenter_config.folder_id
  service_account_id = data.yandex_iam_service_account.tf_backend.id

    platform_id = local.vm_config.platform_id
    
    resources {
      memory = local.vm_config.ram
      cores  = local.vm_config.cores
      core_fraction      = local.vm_config.core_fraction
    }

    scheduling_policy {
      preemptible = local.vm_config.preemptible
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
#        image_id = data.yandex_compute_image.main.id
#        image_id = data.yandex_compute_image.list[count.index].id
	image_id = var.images[count.index]
        size = local.vm_config.disk_size 
        type = local.vm_config.disk_type 
      }
    }

#    provisioner "file" {
#      source      = "docker-compose.yml"
#      destination = "/docker-compose.yml"
#    }

    network_interface {
      subnet_id = var.subnet.id
      nat = var.ext_ifaces[count.index]
      ip_address = var.int_ifaces[count.index]
    }

    metadata = {
#     docker-compose = file("${path.module}/docker-compose.yml")
      user-data = data.template_file.cloudinit.rendered
      serial-port-enable = 1
    }
}



# =====> Outputs from the module:

output "vm_ips" {
  value = yandex_compute_instance.this[*].network_interface[0].nat_ip_address
}

output "vm_ssh_user_name" {
  value = local.vm_config.ssh.user
}

# Upgrade: Unpacking terraform (1.9.4-1) over (1.5.7-1) ...