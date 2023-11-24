variable more_args {
# 	needs dynamic type!
}

resource "yandex_vpc_network" "main" {
  name = var.more_args.env_name
}

resource "yandex_vpc_subnet" "main" {
  name           = "${var.more_args.env_name}-${local.datacenter_info.zone}"
  zone           = local.datacenter_info.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = var.more_args.cidr
}

output result {
  value = {
    network_id = yandex_vpc_network.main.id,
    subnet_id = yandex_vpc_subnet.main.id
  }
}

