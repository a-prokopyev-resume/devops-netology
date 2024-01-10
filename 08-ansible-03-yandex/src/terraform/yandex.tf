#====================================== The Beginning of the Copyright Notice ============================================================
# The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.
# Contact of the AUTHOR: a.prokopyev.resume at gmail dot com
#
# All source code and other content contained in this file is protected by copyright law.
# This file is licensed by the AUTHOR under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
#
# THIS FILE IS LICENSED ONLY PROVIDED FOLLOWING RESTRICTIONS ALSO APPLY:
# Nobody except the AUTHOR may alter or remove this copyright notice from any copies of this file content (including modified fragments).
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
#
# ATTENTION: If potential user's country laws are not compatible or collide with the terms of this copyright notice or if a potential user
# does not agree with the terms of this copyright notice then such potential user is strongly prohibited to use this file by any method.
#=================================== The End of the Copyright Notice =====================================================================

# =====> Service account and its roles:

resource "yandex_iam_service_account" "tf_backend" {
  name = "tf-backend"
  folder_id = local.datacenter_config.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "required_roles" {
  for_each = toset([
    "resource-manager.admin",
    "vpc.admin",
    "compute.admin"
  ])
  folder_id = local.datacenter_config.folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.tf_backend.id}"
  depends_on = [ yandex_iam_service_account.tf_backend ]
}

# =====> VPC network:

resource "yandex_vpc_network" "main" {
  name = "main"
  depends_on = [ yandex_resourcemanager_folder_iam_member.required_roles ]
}

resource "yandex_vpc_subnet" "main" {
  name           = "main"
  zone           = local.datacenter_config.default_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = var.default_cidr
  depends_on = [ yandex_vpc_network.main ]
}

# =====> Compute instances:

data "yandex_compute_image" "container_host" {
  family = local.vm_config.image_family
}

data "template_file" "cloudinit" {
  template = file("cloud-init.yml")
  vars = {
    ssh_user = local.vm_config.ssh.user
    ssh_public_key = local.vm_config.ssh.public_key
  }
}

resource "null_resource" "wait" {
  depends_on = [ yandex_vpc_subnet.main ]
#  when = create
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "sleep 10s"
  }
}

resource "yandex_compute_instance_group" "containers" {
  name = "containers"
  depends_on = [ yandex_vpc_subnet.main ] # yandex_resourcemanager_folder_iam_member.required_roles,
  folder_id = local.datacenter_config.folder_id
  service_account_id = yandex_iam_service_account.tf_backend.id
  
  instance_template {
    platform_id = local.vm_config.platform_id
    
    resources {
      memory = local.vm_config.memory
      cores  = local.vm_config.cores
#      disk {
#        size = local.vm_config.disk_size  # Specify the size of the disk in GB
#        type = "network-ssd"  # Specify the disk type
#      }
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.container_host.id
#        size = local.vm_config.disk_size
      }
    }
    network_interface {
      network_id = yandex_vpc_network.main.id
      subnet_ids = [ yandex_vpc_subnet.main.id ]
      nat = true
    }

    metadata = {
#     docker-container-declaration allows you to use all Yandex Cloud resource features like load balancing, auto-scaling etc. With docker-compose you are limited to what's in the Compose file.
#     docker-container-declaration = file("${path.module}/docker_compose_yc_spec.yaml")
      docker-compose = file("${path.module}/docker-compose.yml")

#     user-data = file("${path.module}/cloud_config.yaml")
      user-data = data.template_file.cloudinit.rendered

      serial-port-enable = 1
    }
  }

  scale_policy {
    fixed_scale {
      size = 1 # One runner is enough for now
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
}

# =====> Outputs from the module:

data "yandex_compute_instance_group" "containers" {
  instance_group_id = yandex_compute_instance_group.containers.id
}

output "vm_ips" {
  value = data.yandex_compute_instance_group.containers.instances[*].network_interface[0].nat_ip_address
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