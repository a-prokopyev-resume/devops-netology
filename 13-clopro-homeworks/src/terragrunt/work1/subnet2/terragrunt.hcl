terraform {
  source = "../../../terraform/subnet"
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "route" {
  config_path = "../route"
}

inputs = {
	subnet_name = "private"
	subnet_cidr = "192.168.20.0/24"
	network_id = dependency.vpc.outputs.network_id
        route_table_id = dependency.route.outputs.route_table_id
}


