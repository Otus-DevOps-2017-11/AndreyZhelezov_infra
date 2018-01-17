resource "google_compute_instance" "app" {
  name         = "${var.instance_app_name}"
  machine_type = "${var.machine_type_app}"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "${var.network_name}"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_address" "app_ip" {
  name = "${var.app_external_if_name}"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "${var.puma_allow_rule_name}"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
