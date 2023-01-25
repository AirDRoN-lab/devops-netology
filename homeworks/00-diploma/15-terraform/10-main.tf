terraform {
  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

 backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "tf-bucket"
    region     = var.ru-central1
    key        = "netology.tfstate"
    access_key = yandex_iam_service_account_static_access_key.tf-sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.tf-sa-static-key.secret_key

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}
