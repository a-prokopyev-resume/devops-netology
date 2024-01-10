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
  token     = local.datacenter_config.token
  cloud_id  = local.datacenter_config.cloud_id
  folder_id = local.datacenter_config.folder_id
  zone      = local.datacenter_config.default_zone
}

