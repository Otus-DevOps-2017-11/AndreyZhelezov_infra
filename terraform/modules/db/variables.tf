variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable instance_db_name {
  description = "Name for db instance"
  default     = "reddit-db"
}

variable machine_type_db {
  description = "Machine type for db instance"
  default     = "g1-small"
}

variable network_name {
  description = "Name for used network"
  default     = "default"
}

variable mongo_allow_rule_name {
  description = "Name for mongo allow network rule"
  default     = "allow-mongo-default"
}
