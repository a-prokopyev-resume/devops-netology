terraform {
  source = "../../../terraform/compute/instance"
}

dependency "subnet1" {
  config_path = "../../subnet1"
}

inputs = {
  subnet = dependency.subnet1.outputs.self
  name = "public"
  int_ifaces = [ "192.168.10.10", "192.168.10.254" ]
  ext_ifaces = [ true, true ]
#  images = [ "debian-11", "nat-instance-ubuntu" ]
#   images = [ "fd8lk4dibrqmhmn8rbc4", "fd8e3t7l6cnusj7777vc" ]
#   images = [ "fd8lk4dibrqmhmn8rbc4", "fd80mrhj8fl2oe87o4e1" ]
  images = [ "fd8lk4dibrqmhmn8rbc4", "fd8mgjvkra979jp2psfe" ]
}
