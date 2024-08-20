terraform {
  source = "../../../terraform/compute/group"
}

dependency "subnet1" {
  config_path = "../../subnet1"
}

dependency "bucket" {
  config_path = "../bucket"
}

#locals {
#   picture_url = "https://storage.yandexcloud.net/${dependency.bucket.outputs.name}/picture.png"
#}

inputs = {
  amount = 3
  subnet = dependency.subnet1.outputs.self
  name = "work2"
  image_id = "fd827b91d99psvq5fjit" # LAMP stack

  user_data = <<EOF
#!/bin/bash
cd /var/www/html
echo '<html><head><title>Welcome to DevOps </title></head> <body>><img src="https://storage.yandexcloud.net/${dependency.bucket.outputs.name}/picture.png"/></body></html>' > index.html
EOF

}
