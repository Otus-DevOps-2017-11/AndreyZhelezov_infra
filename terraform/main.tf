provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)}"
  }
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "${var.zone}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение ssh-ключа пользователя appuser в метаданых инстанса
  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }

  tags = ["reddit-app"]

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    access_config {}
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # название сети, в которой действует правило
  network = "default"

  # какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # правило применимо для инстансов с тегом  ...
  target_tags = ["reddit-app"]
}
