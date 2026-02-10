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
    user        = "ivan"
    private_key = file("~/.ssh/id_ed25519")
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = ["echo 'ВМ загружена, SSH доступен'"]
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i '${self.network_interface.0.nat_ip_address},' playbooks/playbook.yml"
  }
}