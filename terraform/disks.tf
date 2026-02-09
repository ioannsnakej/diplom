resource "yandex_compute_disk" "bookstore-app-boot-disk-1" {
  name     = "bookstore-app-boot-disk-1"
  type     = "network-hdd"
  zone     = var.default_zone
  size     = var.disk_size
  image_id = var.default_image
}