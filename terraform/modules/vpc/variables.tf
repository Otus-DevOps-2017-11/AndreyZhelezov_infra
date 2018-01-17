variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}

variable ssh_fwrule_name {
  description = "Name for ssh allow rule"
  default     = "default-allow-ssh"
}

variable network_name {
  description = "Name for used network"
  default     = "default"
}
