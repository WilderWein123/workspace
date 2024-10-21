resource "yandex_compute_instance" "nginx" {
  count = 2
  name = "nginx${count.index + 1}"
  zone = "ru-central1-${count.index == 0? "a" : "b"}"

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
     subnet_id = count.index == 0? yandex_vpc_subnet.web-sub-a.id : yandex_vpc_subnet.web-sub-b.id
     nat = false
     security_group_ids = [ yandex_vpc_security_group.out_all.id, yandex_vpc_security_group.inc_http.id, yandex_vpc_security_group.inc_zbxagent.id, yandex_vpc_security_group.inc_ssh.id ]
  }

  metadata = {
    user-data = "${file("cloud_conf.yaml")}"
  }
}

output "nginx_web_int" {
  value = tomap ({
    for name, nginx in yandex_compute_instance.nginx : name => nginx.network_interface.0.ip_address
  })
}
