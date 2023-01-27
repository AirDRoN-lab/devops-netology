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
    access_key = var.YC_SA_ACCESSKEY
    secret_key = var.YC_SA_SECRETKEY

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
