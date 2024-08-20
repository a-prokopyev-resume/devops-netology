terraform {
  source = "../../../terraform/bucket"
}

#dependency "vm3" {
#  config_path = "../vmg"
#}

dependency "vpc" {
  config_path = "../../vpc"
}

#inputs = {
#  vm1_ips = dependency.vm1.outputs.vm_ips
#  vm2_ips = dependency.vm2.outputs.vm_ips
#}
