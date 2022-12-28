resource "yandex_compute_instance" "vm-1" {
  name = "nat-instance"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1" #NAT instance
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-01.id
    nat       = true
    ip_address = "192.168.10.254"
  }

  metadata = { 
    user-data = "${file("96-meta.txt")}" #   ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  name = "vm-public"

  resources {
    cores  = 2
    memory = 2
    core_fraction = "20"
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd8firhksp7daa6msfes" #UBUNTU 2004 from YA_base
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-01.id
    nat       = true
  }

  metadata = { 
    user-data = "${file("96-meta.txt")}" #   ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"

  }
}

resource "yandex_compute_instance" "vm-3" {
  name = "vm-private"

  resources {
    cores  = 2
    memory = 2
    core_fraction = "20"
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "fd8firhksp7daa6msfes" #UBUNTU 2004 from YA_base
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-02.id
    #nat       = true
  }

  metadata = { 
    user-data = "${file("96-meta.txt")}" #   ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"

  }
}
