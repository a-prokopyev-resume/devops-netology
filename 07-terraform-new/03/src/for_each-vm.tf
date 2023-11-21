
resource "yandex_compute_instance" "list2" {
  for_each = { for iterator in var.vm_resources : iterator.name => iterator }
  name = each.value.name

  depends_on = [yandex_compute_instance.list1]

  platform_id = each.value.platform_id
  resources {
    cores         = each.value.cores
    memory        = each.value.ram
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type = "network-hdd"
      size = each.value.disk
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys = local.ssh_metadata
  }

}



