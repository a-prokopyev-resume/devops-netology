terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    local = {
      source = "hashicorp/local"
      version="=2.4.0"
    }
  }

}

provider "yandex" {
  token     = local.datacenter_info.token
  cloud_id  = local.datacenter_info.cloud_id
  folder_id = local.datacenter_info.folder_id
  zone      = local.datacenter_info.zone
}

