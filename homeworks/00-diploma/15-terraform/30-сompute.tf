
resource "yandex_compute_instance" "vm1-master" {
  name = "vm-master01"


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

resource "yandex_compute_instance" "vm2-node01" {
  name = "vm-node01"

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

resource "yandex_compute_instance" "vm3-node02" {
  name = "vm-node02"

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