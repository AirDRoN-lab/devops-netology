output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm1-master01.network_interface[0].ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm1-master01.network_interface[0].nat_ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm2-node01.network_interface[0].ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm2-node01.network_interface[0].nat_ip_address
}

output "internal_ip_address_vm_3" {
  value = yandex_compute_instance.vm3-node02.network_interface[0].ip_address
}

output "external_ip_address_vm_3" {
  value = yandex_compute_instance.vm3-node02.network_interface[0].nat_ip_address
}

output "subnet_vm" {
  value = yandex_vpc_subnet.subnet-01.id
}

output "network_vm" {
  value = yandex_vpc_subnet.subnet-01.network_id
}

# output "lb-01" {
#   value = yandex_lb_network_load_balancer.lb-01.listener.*.external_address_spec[0].*.address
# }


