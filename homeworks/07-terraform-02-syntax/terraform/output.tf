output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface[0].ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface[0].nat_ip_address
}

output "subnet_vm_1" {
  value = yandex_vpc_subnet.subnet-1.id
}

output "network_vm_1" {
  value = yandex_vpc_subnet.subnet-1.network_id
}

output "created_at_vm_1" {
  value = yandex_compute_instance.vm-1.created_at
}

output "zone" {
  value = var.yc_zone
}




