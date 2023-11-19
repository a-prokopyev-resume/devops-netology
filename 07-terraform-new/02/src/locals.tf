locals {
  project = "netology-develop-platform"
  env_web = "web"
  env_db  = "db"
  vm_web_name = "${local.project}-${local.env_web}"
  vm_db_name = "${local.project}-${local.env_db}"
}
