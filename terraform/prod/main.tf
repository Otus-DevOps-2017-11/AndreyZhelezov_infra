provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source               = "../modules/app"
  public_key_path      = "${var.public_key_path}"
  zone                 = "${var.zone}"
  app_disk_image       = "${var.app_disk_image}"
  instance_app_name    = "reddit-app-prod"
  machine_type_app     = "g1-small"
  puma_allow_rule_name = "allow-puma-prod"
  app_external_if_name = "reddit-app-ip-prod"
}

module "db" {
  source                = "../modules/db"
  public_key_path       = "${var.public_key_path}"
  zone                  = "${var.zone}"
  db_disk_image         = "${var.db_disk_image}"
  instance_db_name      = "reddit-db-prod"
  machine_type_db       = "g1-small"
  mongo_allow_rule_name = "allow-mongo-prod"
}

module "vpc" {
  source          = "../modules/vpc"
  source_ranges   = ["213.150.75.34/32"]
  ssh_fwrule_name = "prod-allow-ssh"
}
