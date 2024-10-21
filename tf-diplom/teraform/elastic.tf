resource "yandex_compute_instance" "elastic" {
  name = "elastic"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd833v6c5tb0udvk4jo6"
      size=10
    }
  }

  scheduling_policy {
#    preemptible = true
  }

  network_interface {
     subnet_id = yandex_vpc_subnet.web-sub-a.id
     security_group_ids = [ yandex_vpc_security_group.out_all.id, yandex_vpc_security_group.inc_zbxagent.id, yandex_vpc_security_group.inc_elk.id, yandex_vpc_security_group.inc_ssh.id ]
  }
  
  metadata = {
    user-data = "${file("cloud_conf.yaml")}"
  }
}

output "elastic_int"{
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}
