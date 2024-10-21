resource "yandex_vpc_network" "web-network" {
  name = "web-network"
}

resource "yandex_vpc_subnet" "web-sub-a" {
  name           = "web-sub-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.web-network.id
  v4_cidr_blocks = ["192.168.253.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}

resource "yandex_vpc_subnet" "web-sub-b" {
  name           = "web-sub-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.web-network.id
  v4_cidr_blocks = ["192.168.254.0/24"]
  route_table_id = yandex_vpc_route_table.route_table.id
}
resource "yandex_vpc_gateway" "natgateway" {
  name = "natgateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_table" {
  name       = "route_table"
  network_id = yandex_vpc_network.web-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.natgateway.id
  }
}

resource "yandex_alb_target_group" "nginx-targetgroup" {
  name = "nginx-targetgroup"
  target {
    subnet_id = yandex_vpc_subnet.web-sub-a.id
    ip_address = yandex_compute_instance.nginx[0].network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.web-sub-b.id
    ip_address = yandex_compute_instance.nginx[1].network_interface.0.ip_address
  }
}

resource "yandex_alb_load_balancer" "web-lb" {
  name = "web-lb"
  network_id = yandex_vpc_network.web-network.id
  allocation_policy {
    location {
      zone_id = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.web-sub-a.id
    }
    location {
      zone_id = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.web-sub-b.id
    }
  }
  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.webrouter.id
      }
    }
  }
}

resource "yandex_alb_backend_group" "backend-group-nginx" {
  name = "backend-group-nginx"
  http_backend {
    name = "nginx-backend"
    port = "80"
  target_group_ids = [yandex_alb_target_group.nginx-targetgroup.id]
    healthcheck {
      timeout = "10s"
      interval = "10s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "webrouter" {
  name      = "webrouter"
}

resource "yandex_alb_virtual_host" "nginx-virthost" {
  name = "nginx-virthost"
  http_router_id = yandex_alb_http_router.webrouter.id
  route {
    name = "nginx-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group-nginx.id
      }
    }
  }
  
}

output "load_balancer_ip" {
  value = yandex_alb_load_balancer.web-lb.listener.0.endpoint.0.address.0.external_ipv4_address[0].address
}

# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/../ansible/hosts.tpl",
    {
      nginxes = yandex_compute_instance.nginx[*].network_interface.0.ip_address
      zabbix = yandex_compute_instance.zabbix.network_interface.0.ip_address
      elastic = yandex_compute_instance.elastic.network_interface.0.ip_address
      kibana = yandex_compute_instance.kibana.network_interface.0.ip_address
    }
  )
  filename = "../ansible/hosts"
}
