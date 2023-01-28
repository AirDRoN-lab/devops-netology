variable "YC_TOKEN" {
  type = string
}

variable "YC_CLOUD_ID" {
  type = string
}

variable "YC_FOLDER_ID" {
  type = string
}

# variable "YC_SA_ACCESSKEY" {
#   type = string
# }

# variable "YC_SA_SECRETKEY" {
#   type = string
# }\

variable "YC_ZONE" {
  default = "ru-central1-a"
  #  default=env("YC_ZONE")
}

variable "YC_REGION" {
  default = "ru-central1"
  #  default=env("YC_REGION")
}
