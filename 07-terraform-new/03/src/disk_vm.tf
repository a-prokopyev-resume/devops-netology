resource "yandex_compute_disk" "disks" {
  count = 3
  size = 1
  // auto_delete = true // does not exist, but present in the plan?
}

resource "yandex_compute_instance" "storage" {
    name        = "storage"
    depends_on = [yandex_compute_disk.disks]
    platform_id = "standard-v2"
    resources {
        cores         = 2
        memory        = 1
        core_fraction = 5
    }
    boot_disk {
        initialize_params {
        image_id = data.yandex_compute_image.ubuntu.image_id
        }
    }
    dynamic "secondary_disk" {
        for_each = yandex_compute_disk.disks.*.id // yandex_compute_disk.disks[*].id
        content {
            disk_id = secondary_disk.value
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