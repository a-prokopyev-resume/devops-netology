#=============================================== The Beginning of the Copyright Notice ===================================================
# The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.
# Contact of the AUTHOR: a.prokopyev.resume at gmail dot com
# WWW: https://github.com/a-prokopyev-resume/devops-netology
#
# All source code and other content contained in this file is protected by copyright law.
# This file is licensed by the AUTHOR under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
#
# THIS FILE IS LICENSED ONLY PROVIDED FOLLOWING RESTRICTIONS ALSO APPLY:
# Nobody except the AUTHOR may alter or remove this copyright notice from any copies of this file content (including modified fragments).
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
#
# ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or 
# if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or licensee  
# is STRONGLY PROHIBITED to use this file by any method.
#================================================== The End of the Copyright Notice ======================================================


data "yandex_iam_service_account" "tf_backend" {
  name = "tf-backend"
}

locals {
    bucket = "alex.pro-${formatdate("YYYY-MM-DD-HH-mm-ss", timestamp())}"
}

resource "yandex_iam_service_account_static_access_key" "this" {
  service_account_id = data.yandex_iam_service_account.tf_backend.id
}

resource "yandex_storage_bucket" "picture" {
  access_key = yandex_iam_service_account_static_access_key.this.access_key
  secret_key = yandex_iam_service_account_static_access_key.this.secret_key
  bucket = local.bucket
  acl    = "public-read"
#  max_size = 100000
  force_destroy = true

  lifecycle_rule {
    enabled = true
    expiration {
      days = 1
    }
  }


}

resource "yandex_storage_object" "this" {
  access_key = yandex_iam_service_account_static_access_key.this.access_key
  secret_key = yandex_iam_service_account_static_access_key.this.secret_key
  bucket = local.bucket
  key    = "picture.png"
  source = "picture.png"
  acl = "public-read"
  depends_on = [yandex_storage_bucket.picture]
}


# =====> Outputs from the module:

output "name" {
   value = yandex_storage_bucket.picture.bucket
}

