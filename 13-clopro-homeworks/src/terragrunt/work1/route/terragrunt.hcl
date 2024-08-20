terraform {
  source = "../../../terraform/route"
}

dependency "vpc" {
  config_path = "../../vpc"
}
