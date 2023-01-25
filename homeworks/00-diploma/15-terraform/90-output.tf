output "network-01" {
  value = yandex_vpc_network.vpc-netology.id
}

output "subnet-01" {
  value = yandex_vpc_subnet.subnet-01.id
}

output "lb-01" {
  value = yandex_lb_network_load_balancer.lb-01.listener.*.external_address_spec[0].*.address
}


