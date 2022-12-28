output "internal_ip_address_NAT-instance" {
  value = yandex_compute_instance.vm-1.network_interface[0].ip_address
}

output "external_ip_address_NAT-instance" {
  value = yandex_compute_instance.vm-1.network_interface[0].nat_ip_address
}

output "internal_ip_address_VM-public" {
  value = yandex_compute_instance.vm-2.network_interface[0].ip_address
}

output "external_ip_address_VM-public" {
  value = yandex_compute_instance.vm-2.network_interface[0].nat_ip_address
}

output "internal_ip_address_VM-private" {
  value = yandex_compute_instance.vm-3.network_interface[0].ip_address
}

output "vpc-netology" {
  value = yandex_vpc_network.vpc-netology.id
}

output "subnet-01_vpc" {
  value = yandex_vpc_subnet.subnet-01.id
}

output "subnet-02_vpc" {
  value = yandex_vpc_subnet.subnet-02.id
}

