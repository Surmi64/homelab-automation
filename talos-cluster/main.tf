provider "proxmox" {
  endpoint = "https://192.168.0.111:8006"
  insecure = true

  ssh {
    agent = true
  }

}
