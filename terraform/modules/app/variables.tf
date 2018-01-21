variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable instance_app_name {
  description = "Name for app instance"
  default     = "reddit-app"
}

variable machine_type_app {
  description = "Machine type for app instance"
  default     = "g1-small"
}

variable network_name {
  description = "Name for used network"
  default     = "default"
}

variable puma_allow_rule_name {
  description = "Name for puma allow network rule"
  default     = "allow-puma-default"
}

variable nginx_allow_rule_name {
  description = "Name for nginx allow network rule"
  default     = "allow-nginx-default"
}

variable app_external_if_name {
  description = "Name for external network interface"
  default     = "reddit-app-ip"
}
