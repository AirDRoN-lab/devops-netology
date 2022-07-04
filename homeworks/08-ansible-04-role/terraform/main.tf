terraform {
  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

resource "yandex_compute_instance" "vm-1" {
  name = "clickhouse"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8firhksp7daa6msfes" #UBUNTU 2004 from YA_base
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = { 
    user-data = "${file("meta.txt")}" #   ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"

  }
}

resource "yandex_compute_instance" "vm-2" {
  name = "vector"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8firhksp7daa6msfes" #UBUNTU 2004 from YA_base
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = { 
    user-data = "${file("meta.txt")}" #   ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"

  }
}

resource "yandex_compute_instance" "vm-3" {
  name = "lighthouse"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8firhksp7daa6msfes" #UBUNTU 2004 from YA_base
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = { 
    user-data = "${file("meta.txt")}" #   ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"

  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.250.0/24"]
}
