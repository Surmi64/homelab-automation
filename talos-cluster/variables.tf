variable "cluster_name" {
  type    = string
  default = "cluster"
}

variable "default_gateway" {
  type    = string
  default = "192.168.0.1"
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "192.168.0.241"
}

variable "talos_worker_01_ip_addr" {
  type    = string
  default = "192.168.0.242"
}
