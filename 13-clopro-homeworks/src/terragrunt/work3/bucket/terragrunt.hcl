terraform {
  source = "../../../terraform/bucket"
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "encrypt" {
  config_path = "../encrypt"
}

inputs = {
  key_id = dependency.encrypt.outputs.key_id
}
