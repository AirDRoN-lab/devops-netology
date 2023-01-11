
resource "yandex_lb_target_group" "lb-target-group-001" {
  name      = "lb-target-group-001"
  region_id = var.yc_region

  # target {
  # subnet_id = "${yandex_vpc_subnet.subnet-01.id}"
  # address   = "${yandex_compute_instance_group.ig-01.instances.*.network_interface.0.ip_address}"
  # }
}

resource "yandex_lb_network_load_balancer" "lb-01" {
  name = "lb-01"
  listener {
    name = "lb-ls-01"
    port = 80
    # external_address_spec {
    #   ip_version = "ipv4"
    # }
  }
  attached_target_group {
    target_group_id = "${yandex_lb_target_group.lb-target-group-001.id}"
    healthcheck {
      name = "hc-http"
        http_options {
          port = 80
          path = "/"
        }
    }
  }
}