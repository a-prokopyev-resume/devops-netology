terraform {
  source = "../../../terraform/encrypt"
}

dependency "vpc" {
  config_path = "../../vpc"
}

