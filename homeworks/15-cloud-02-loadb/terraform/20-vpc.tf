resource "yandex_vpc_network" "vpc-netology" {
  folder_id = var.yc_folder_id
  name = "vpc-netology"
}

resource "yandex_vpc_subnet" "subnet-01" {
  folder_id = var.yc_folder_id
  name           = "subnet-01"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
