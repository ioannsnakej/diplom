resource "yandex_compute_instance" "bookstore-app" {
  name        = "bookstore-app"
  hostname    = "bookstore-app"
  platform_id = "standard-v3"

  resources {
    cores  = var.default_vcpu
    memory = var.default_memory
  }

  boot_disk {
    initialize_params {
      type     = "network-hdd"
      image_id = var.default_image
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id = var.default_subnet
    nat       = true
  }

  metadata = {
    user-data = "${file("./users.txt")}"
  }

  connection {
    host        = self.network_interface.0.nat_ip_address
    user        = "gitlab-runner"
    agent       = true
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = ["echo 'ВМ загружена, SSH доступен'"]
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i '${self.network_interface.0.nat_ip_address},' playbooks/playbook.yml"
  }
}

output "instance_ip" {
    value = yandex_compute_instance.bookstore-app.network_interface.0.nat_ip_address
    description = "Public IP of bookstore-app VM"
}