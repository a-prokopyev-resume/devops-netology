terraform {
  source = "../../../terraform/bucket"
}

dependency "vpc" {
  config_path = "../../vpc"
}
