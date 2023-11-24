#=== Service account
resource "yandex_iam_service_account" "tf_backend" {
  name = "tf-backend"
  folder_id = local.datacenter_info.folder_id
}

#=== Service account static key
resource "yandex_iam_service_account_static_access_key" "tf_backend" {
  service_account_id = yandex_iam_service_account.tf_backend.id
  description        = "Static access key."
}

#=== Storage editor role
resource "yandex_resourcemanager_folder_iam_member" "storage_editor_role" {
  folder_id = local.datacenter_info.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.tf_backend.id}"
}

#=== Storage uploader role
resource "yandex_resourcemanager_folder_iam_member" "storage_uploader_role" {
  folder_id = local.datacenter_info.folder_id
  role      = "storage.uploader"
  member    = "serviceAccount:${yandex_iam_service_account.tf_backend.id}"
}

#=== Storage bucket for Terraform backend
resource "yandex_storage_bucket" "tf_backend" {
  bucket     = "terraform5"
  access_key = yandex_iam_service_account_static_access_key.tf_backend.access_key
  secret_key = yandex_iam_service_account_static_access_key.tf_backend.secret_key
  max_size   = 1048576 # Specified in bytes
  depends_on = [ yandex_resourcemanager_folder_iam_member.storage_editor_role ]
}

#=== YDB admin role
resource "yandex_resourcemanager_folder_iam_member" "ydb_admin_role" {
  folder_id = local.datacenter_info.folder_id
  role      = "ydb.admin"
  member    = "serviceAccount:${yandex_iam_service_account.tf_backend.id}"
}

#=== YDB database for Terraform backend
resource "yandex_ydb_database_serverless" "tf_backend" {
  name = "terraform-state-db-serverless"
  serverless_database {
    storage_size_limit          = 1 # Specified in gigabytes
  }
  depends_on = [ yandex_resourcemanager_folder_iam_member.ydb_admin_role ]
}

# shell: yc ydb database add-access-binding --service-account-name "tf-backend" --role "ydb.admin" --name terraform-state-db-serverless

resource "yandex_ydb_table" "tf_backend" {
    path = "terraform_locks"
    connection_string = yandex_ydb_database_serverless.tf_backend.ydb_full_endpoint
    primary_key = [ "LockID" ]
    column {
        name = "LockID"
        type = "String"
    }
}

resource "local_file" "tf_backend" {
  filename = ".secrets/backend.tf.generated"
  content = templatefile("backend.tftpl", { 
    static_access_key=yandex_iam_service_account_static_access_key.tf_backend
    bucket=yandex_storage_bucket.tf_backend.bucket
    datacenter_info = local.datacenter_info
    ydb = yandex_ydb_database_serverless.tf_backend
  })
}

output "tf_backend_secret_keys" {
	value = {
		sa_id = yandex_iam_service_account.tf_backend.id,
		access_key = yandex_iam_service_account_static_access_key.tf_backend.access_key
    secret_key = yandex_iam_service_account_static_access_key.tf_backend.secret_key
	}
	sensitive = true
}
