resource "yandex_vpc_network" "vpc-netology" {
  name = "netology-diploma"
}

resource "yandex_vpc_subnet" "subnet-01" {
  name           = "public-subnet-01"
  zone           = var.YC_ZONE
  network_id     = yandex_vpc_network.vpc-netology.id
  v4_cidr_blocks = ["192.168.10.0/24"]
# route_table_id = yandex_vpc_route_table.to-inet.id
}
