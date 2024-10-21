resource "yandex_compute_instance" "bastion" {
  name = "bastion"
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
     security_group_ids =  [ yandex_vpc_security_group.out_all.id, yandex_vpc_security_group.inc_ssh_global.id, yandex_vpc_security_group.inc_zbxagent.id ]
  }
  
  metadata = {
    user-data = "${file("cloud_conf.yaml")}"
  }
}


output "bastion_ext"{
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

resource "null_resource" "ansible" {
    connection {
      type        = "ssh"
      user        = local.local_admin
      private_key = file(local.local_admin_private_key)
      host = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    }
  provisioner "file"{
    source = "../ansible"
    destination = "/tmp"
  }
  provisioner "file"{
    source = "/data/distribs/Linux/elasticsearch/"
    destination = "/tmp"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt install ansible zabbix-agent -y",
      ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt install ansible zabbix-agent -y",
      "cd /tmp/ansible",
      "sudo chmod 600 id_rsa",
      "ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i /tmp/ansible/hosts -u ${local.local_admin} --private-key /tmp/ansible/id_rsa /tmp/ansible/nginx.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i /tmp/ansible/hosts -u ${local.local_admin} --private-key /tmp/ansible/id_rsa /tmp/ansible/zabbix.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i /tmp/ansible/hosts -u ${local.local_admin} --private-key /tmp/ansible/id_rsa /tmp/ansible/elastic.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i /tmp/ansible/hosts -u ${local.local_admin} --private-key /tmp/ansible/id_rsa /tmp/ansible/kibana.yml"
      ]
  }
}
