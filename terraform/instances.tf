resource "yandex_compute_instance" "bookstore-app" {
    name = "bookstore-app"
    hostname = "bookstore-app"
    platfirm_id = "standard-v3"

    resources {
        core = var.default_vcpu
        memory = var.default_memory
    }

    boot_disk {
        disk_id = yandex_compute_disk.bookstore-app-boot-disk-1.id
    }

    network_interface {
        subnet_id = var.default_subnet
        nat = true
    }

    metadata = {
        user-data = "${file("./users.txt")}"
    }

    connection {
        host = self.network_interface.0.nat_ip_address
        type = "ssh"
        user = "ivan"
        private_key = file("~/.ssh/id_ed25519")
        timeout = "5m"
    }

    provisioner "local-exec" {
        command = "cd ../ansible && ansible-playbook -i '${self.network_interface.0.nat_ip_address},' ./playbooks/playbook.yml"
    }
}