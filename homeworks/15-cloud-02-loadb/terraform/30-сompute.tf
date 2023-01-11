resource "yandex_compute_instance_group" "ig-01" {
  name               = "ig-01"
  service_account_id = "${yandex_iam_service_account.sa.id}"

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 2
      core_fraction = "20"
    }

    scheduling_policy {
      preemptible = true
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit" #LAMP
      }
    }

    network_interface {
      subnet_ids = ["${yandex_vpc_subnet.subnet-01.id}"]
      #nat       = true
    }

    metadata = { 
      user-data = "${file("96-meta-01.txt")}" #   ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  # load_balancer {
  #   target_group_name        = "lb-target-group-01"
  #   target_group_description = "load balancer target group for web service"
  # }
}



