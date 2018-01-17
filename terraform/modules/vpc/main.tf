resource "google_compute_firewall" "firewall_ssh" {
  name    = "${var.ssh_fwrule_name}"
  network = "${var.network_name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.source_ranges}"
}
