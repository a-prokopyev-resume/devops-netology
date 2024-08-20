terraform {
  source = "../../../terraform/compute/instance"
}

dependency "subnet2" {
  config_path = "../subnet2"
#  skip_outputs = true
}

inputs = {
  subnet = dependency.subnet2.outputs.self
  name = "private"
  int_ifaces = [ "192.168.20.20" ]
  ext_ifaces = [ false ]
#  images = [ "debian-11" ]
  images = [ "fd8lk4dibrqmhmn8rbc4" ]
}
