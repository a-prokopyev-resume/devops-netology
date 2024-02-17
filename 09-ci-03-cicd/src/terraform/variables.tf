#=============================================== The Beginning of the Copyright Notice ===================================================
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
# ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or 
# if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or licensee  
# is STRONGLY PROHIBITED to use this file by any method.
#================================================== The End of the Copyright Notice ======================================================

# =====> Default values for these variables are defined in the personal.auto.tfvars

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
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "group" {
  type		= string
  default	= ""
  description = "Yandex compute group name"
}

variable "amount" {
  type		= number
  default	= 1
  description = "Total amount of virtual machines created in the group"
}

variable "cores" {
  type        	= number
  default 	= 2
  description 	= "Number of CPU cores allocated in each VM"
}

variable "ram" {
  type        	= number
  default	= 1
  description 	= "Memory allocated in each VM"
}

variable "image_family" {
  type		= string
  default	= "container-optimized-image"
  description = "YC disk image name"
}

# =====> Seldom changed parameters defined locally in this file

locals { 

  datacenter_config  =  {
    token=var.token
    cloud_id=var.cloud_id
    folder_id=var.folder_id
    default_zone=var.default_zone
    default_cidr = var.default_cidr
  }

  vm_config = {
    image_family = var.image_family
    platform_id = "standard-v3"
    amount = var.amount
    ram = var.ram
    group =  (var.group == "") ? "yandex-yml-${formatdate("YYYY-MM-DD", timestamp())}" : var.group
    
    cores  = var.cores
    core_fraction = 20 # Allowed values: 20 | 50 | 100
    disk_size = 5 # Not used now
    ssh = {
      user = "netology" # "ssh-keygen -t ed25519"
      public_key = "${file("~/.ssh/id_ed25519.pub")}"
    }

  }

}
