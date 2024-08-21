terraform {
  source = "../../../terraform/subnet"
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
	subnet_name = "public"
	subnet_cidr = "192.168.10.0/24"
	network_id = dependency.vpc.outputs.network_id
#        route_table_id = dependency.route.outputs.route_table_id
}

