variable "YC_TOKEN" {
  type = string
#  default = env("YC_TOKEN")
}

variable "YC_CLOUD_ID" {
  type = string
#  default = env("YC_CLOUD_ID")
}

variable "YC_FOLDER_ID" {
  type = string
#  default=env("YC_FOLDER_ID")
}

variable "yc_zone" {
  default = "ru-central1-a"
}

variable "yc_region" {
  default = "ru-central1"
}

# variable "pic_url" {
#   default = "'https://storage.yandexcloud.net/ya-bucket-001/sigal.jpg'"
# }