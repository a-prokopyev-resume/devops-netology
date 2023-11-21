resource "local_file" "ansible_hosts" {
  filename = "./ansible_hosts.cfg"
  content = templatefile("ansible_hosts.tftpl", {
      ansible_host_groups = [
        {
          group_name = "webservers"
          compute_instance_list = yandex_compute_instance.list1
        },
        {
          group_name = "databases"
          compute_instance_list = yandex_compute_instance.list2
        },
        {
          group_name = "databases"
          compute_instance_list = [ yandex_compute_instance.storage ]
        }
      ]
  })
}
