resource "yandex_lb_network_load_balancer" "lb-01" {
  name = "lb-01"
  folder_id = var.yc_folder_id
  listener {
    name = "lb-ls-01"
    port = 80
  }
  
  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-01.load_balancer.0.target_group_id

    healthcheck {
      name = "hc-http"
        http_options {
          port = 80
          path = "/"
        }
    }
  }
}