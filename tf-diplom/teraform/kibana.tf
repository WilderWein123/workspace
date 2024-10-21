resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 1
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
     nat = true
     index = 0
     security_group_ids = [ yandex_vpc_security_group.out_all.id, yandex_vpc_security_group.inc_kibana.id, yandex_vpc_security_group.inc_ssh.id, yandex_vpc_security_group.inc_zbxagent.id ]
  }
  
  metadata = {
    user-data = "${file("cloud_conf.yaml")}"
  }
}

output "kibana_ext"{
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "kibana_int"{
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}
