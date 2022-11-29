output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface[0].ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface[0].nat_ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface[0].ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface[0].nat_ip_address
}

output "internal_ip_address_vm_3" {
  value = yandex_compute_instance.vm-3.network_interface[0].ip_address
}

output "external_ip_address_vm_3" {
  value = yandex_compute_instance.vm-3.network_interface[0].nat_ip_address
}

output "internal_ip_address_vm_4" {
  value = yandex_compute_instance.vm-4.network_interface[0].ip_address
}

output "external_ip_address_vm_4" {
  value = yandex_compute_instance.vm-4.network_interface[0].nat_ip_address
}

output "internal_ip_address_vm_5" {
  value = yandex_compute_instance.vm-5.network_interface[0].ip_address
}

output "external_ip_address_vm_5" {
  value = yandex_compute_instance.vm-5.network_interface[0].nat_ip_address
}

output "subnet_vm" {
  value = yandex_vpc_subnet.subnet-1.id
}

output "network_vm" {
  value = yandex_vpc_subnet.subnet-1.network_id
}