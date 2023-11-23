/*
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}
*/

 backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "firstbacket1"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true

        dynamodb_endpoint = ""
        dynamodb_table    = "terraform-lock"
  }
}
provider "yan

module "udjin10-module" {
  source          = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name        = "develop"
  network_id      = module.my_vpc.result.network_id
  subnet_zones    = [ var.default_zone ]
  subnet_ids      = [ module.my_vpc.result.subnet_id ]
  instance_name   = var.vm_web_name
  instance_count  = 1
  image_family    = var.vm_image_family 
  public_ip       = true

  metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = 1
  }

}

module "my_vpc" {
  source       = "./vpc"
  datacenter_info = local.datacenter_info
  more_args = {
    env_name     = "develop",
//  zone = var.default_zone,
    cidr = var.default_cidr
  }
}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    ssh_user = var.ssh_user
    ssh_public_key = local.ssh_public_key
  }
}
