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

# =====> Compute instances:

variable "subnet" {
  type        = object({
	id            = string
	network_id    = string
  })
}

variable "name" {
  type        = string
}

variable "image_id" {
  type	      = string
}

variable "user_data" {
  type        = string
  default     = ""
}

data "yandex_iam_service_account" "tf_backend" {
  name = "tf-backend"
}

data "template_file" "cloudinit" {
  template = file("cloud-init.yml")
  vars = {
    ssh_user = local.vm_config.ssh.user
    ssh_public_key = local.vm_config.ssh.public_key
  }
}

resource "null_resource" "wait" {
#  depends_on = [ yandex_vpc_subnet.main ]
#   depends_on = [ data.yandex_vpc_subnet.main ]
#  when = create
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "sleep 15s"
  }
}

resource "yandex_compute_instance_group" "this" {
  name = var.name #local.vm_config.group #
#  depends_on = [ data.yandex_vpc_subnet.main ] # yandex_resourcemanager_folder_iam_member.required_roles,
  folder_id = local.datacenter_config.folder_id
  service_account_id = data.yandex_iam_service_account.tf_backend.id
  
  instance_template {
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
        image_id = var.image_id
        size = local.vm_config.disk_size 
        type = local.vm_config.disk_type 
      }
    }

    network_interface {
      network_id = var.subnet.network_id
      subnet_ids = [ var.subnet.id ]
      nat = true
    }

    metadata = {
#     docker-compose = file("${path.module}/docker-compose.yml")
#     user-data = file("${path.module}/cloud_config.yaml")
#      user-data = data.template_file.cloudinit.rendered
      user-data = var.user_data
      ssh-keys = "root:${file("~/.ssh/id_ed25519.pub")}"
      serial-port-enable = 1
    }

  }

  scale_policy {
    fixed_scale {
      size = local.vm_config.amount
    }
  }

  allocation_policy {
    zones = [ local.datacenter_config.default_zone ]
  }

  deploy_policy {
    max_unavailable = 10
    max_creating = 10
    max_expansion = 10
    max_deleting = 10
  }

  health_check {
    interval = 20
    timeout  = 10
    tcp_options {
      port = 80
    }
  }

#  load_balancer {
##    target_group_name = var.name
#    target_group_name = "work2-tg"
#  }

}

resource "yandex_lb_target_group" "this" {
  name      = "work2-tg"
# region_id = local.datacenter_config.region_id # missing yet
# region_id = "ru-central1"
  dynamic "target" {
    for_each = toset(yandex_compute_instance_group.this.instances)
    content {
#      target {
        subnet_id = "${var.subnet.id}"
        address   = "${target.value.network_interface[0].ip_address}"
#	address   = "${yandex_compute_instance_group.this.instances[0].network_interface[0].ip_address}"
#      }
    }
  }
}

resource "yandex_lb_network_load_balancer" "this" {
  name = "${var.name}-lb"

  listener {
    name = "${var.name}-lb-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
#    target_group_id = yandex_compute_instance_group.this.load_balancer[0].target_group_id
    target_group_id = yandex_lb_target_group.this.id

    healthcheck {
      name = "${var.name}-lb-healthcheck"
      http_options {
        port = 80
        path = "/"
      }
    }
  }

  depends_on = [ yandex_compute_instance_group.this ]
}

# =====> Outputs from the module:

#data "yandex_compute_instance_group" "this" {
#  instance_group_id = yandex_compute_instance_group.containers.id
#}

output "ext_ips" {
  value = yandex_compute_instance_group.this.instances[*].network_interface[0].nat_ip_address
}

output "vm_ssh_user_name" {
  value = local.vm_config.ssh.user
}

# ===== UNUSED Examples:


// journalctl -u yc-container-daemon

/*
/opt/ycloud-tools/yc-container-daemon --help
2024/01/10 02:47:19 warning: systemd notify is disabled
yc-container-daemon starts and stops docker containers based on container specification in metadata

Usage:
  yc-container-daemon [flags]
  yc-container-daemon [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  help        Help about any command
  version     version of yc-container-daemon

Flags:
  -h, --help                help for yc-container-daemon
      --interval duration   Interval between update checks in metadata (default 5s)
      --once                Check metadata once and exit
*/

/*
locals {
  iam_roles = [
    "resource-manager.admin",
    "vpc.admin",
    "compute.admin"
  ]
}

# Method 1 to assign admin role to a single member
resource "yandex_resourcemanager_folder_iam_member" "compute_admin" {
  folder_id = local.datacenter_config.folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.tf_backend.id}"
}

## Method 2 to assign admin role to several members at once
#resource "yandex_resourcemanager_folder_iam_binding" "instance_group_admin" {
#  folder_id = local.datacenter_config.folder_id 
#  role      = "compute.admin"
#  members = [
#    "serviceAccount:${yandex_iam_service_account.tf_backend.id}",
#  ]
#}

resource "yandex_resourcemanager_folder_iam_member" "vpc_admin" {
  folder_id = local.datacenter_config.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.tf_backend.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "resource_manager_admin" {
  folder_id = local.datacenter_config.folder_id
  role      = "resource-manager.admin"
  member    = "serviceAccount:${yandex_iam_service_account.tf_backend.id}"
}
*/

# Upgrade: Unpacking terraform (1.9.4-1) over (1.5.7-1) ...