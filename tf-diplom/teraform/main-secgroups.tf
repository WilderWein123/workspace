resource "yandex_vpc_security_group" "inc_http" {
    network_id = yandex_vpc_network.web-network.id
    name = "inc_http"

    ingress {
        protocol = "TCP"
        port = "80"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "inc_kibana" {
    network_id = yandex_vpc_network.web-network.id
    name = "inc_kibana"

    ingress {
        protocol = "TCP"
        port = "5601"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "inc_elk" {
    network_id = yandex_vpc_network.web-network.id
    name = "inc_elk"

    ingress {
        protocol = "TCP"
        port = "9200"
        v4_cidr_blocks = ["192.168.0.0/16"]
    }
}

resource "yandex_vpc_security_group" "inc_ssh_global" {
    name = "inc_ssh_global"
    network_id = yandex_vpc_network.web-network.id
    ingress {
        protocol = "TCP"
        port = "22"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "inc_ssh" {
    name = "inc_ssh"
    network_id = yandex_vpc_network.web-network.id
    ingress {
        protocol = "TCP"
        port = "22"
        v4_cidr_blocks = ["192.168.0.0/16"]
    }
}

resource "yandex_vpc_security_group" "inc_zbxagent" {
    name = "inc_zbxagent"
    network_id = yandex_vpc_network.web-network.id
    ingress {
        protocol = "TCP"
        port = "10050"
        v4_cidr_blocks = ["192.168.0.0/16"]
    }
}

resource "yandex_vpc_security_group" "out_all" {
    name = "out_all"
    network_id = yandex_vpc_network.web-network.id
    egress {
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}
