resource "google_compute_instance" "db" {
  name         = "${var.instance_db_name}"
  machine_type = "${var.machine_type_db}"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
    network       = "${var.network_name}"
    access_config = {}
  }

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "${var.mongo_allow_rule_name}"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  # правило применяется к инстансам с тегом ...
  target_tags = ["reddit-db"]

  # порт будет доступен только для инстансов с тегом  ...
  source_tags = ["reddit-app"]
}
