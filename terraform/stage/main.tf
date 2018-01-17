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
  instance_app_name    = "reddit-app-stage"
  machine_type_app     = "f1-micro"
  puma_allow_rule_name = "allow-puma-stage"
  app_external_if_name = "reddit-app-ip-stage"
}

module "db" {
  source                = "../modules/db"
  public_key_path       = "${var.public_key_path}"
  zone                  = "${var.zone}"
  db_disk_image         = "${var.db_disk_image}"
  instance_db_name      = "reddit-db-stage"
  machine_type_db       = "f1-micro"
  mongo_allow_rule_name = "allow-mongo-stage"
}

module "vpc" {
  source          = "../modules/vpc"
  source_ranges   = ["0.0.0.0/0"]
  ssh_fwrule_name = "stage-allow-ssh"
}
