
# Talos Kubernetes Cluster on Proxmox via Terraform

This Terraform project provisions a Kubernetes cluster using Talos Linux on a Proxmox VE environment. It automates the setup of control plane and worker nodes, downloads Talos images, configures Talos machine secrets, bootstraps the cluster, and generates the required `talosconfig` and `kubeconfig`.

---

## 📁 Project Structure

- `cluster.tf`: Manages Talos secrets, configuration generation, machine config application, cluster bootstrapping, and health checks.
- `virtual_machines.tf`: Defines the Proxmox virtual machines for control plane and worker nodes.
- `files.tf`: Downloads the Talos nocloud image for VM provisioning.
- `main.tf`: Configures the Proxmox provider connection.
- `providers.tf`: Declares required providers (`proxmox`, `talos`) and their versions.
- `variables.tf`: Declares IPs and networking variables.

---

## ⚙️ Requirements

- **Terraform** >= 1.0
- Proxmox VE cluster with API access
- Proxmox provider: `bpg/proxmox` v0.74.1
- Talos provider: `siderolabs/talos` v0.7.1
- SSH Agent forwarding enabled for the Proxmox provider

---

## 📦 Providers

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.74.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.1"
    }
  }
}
```

---

## 🌐 Variables

| Name                    | Default         | Description                        |
|-------------------------|-----------------|------------------------------------|
| `cluster_name`          | `"cluster"`     | Name of the Proxmox cluster        |
| `default_gateway`       | `"192.168.0.1"` | Default gateway for VMs           |
| `talos_cp_01_ip_addr`   | `"192.168.0.241"` | IP address for the control plane  |
| `talos_worker_01_ip_addr` | `"192.168.0.242"` | IP address for the worker node     |

---

## 🖥️ Virtual Machines

### Control Plane Node: `talos_cp_01`

- 4 CPU cores
- 8GB RAM
- Boots from downloaded Talos image
- Configured with static IP `${var.talos_cp_01_ip_addr}`

### Worker Node: `talos_worker_01`

- 3 CPU cores
- 8GB RAM
- Static IP `${var.talos_worker_01_ip_addr}`
- Depends on control plane being up first

Both VMs use NoCloud initialization and are connected via `vmbr0`.

---

## 📥 Talos Image

Downloads Talos NoCloud image:

```hcl
resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  file_name = "talos-${local.talos.version}-nocloud-amd64.img"
  url       = "https://factory.talos.dev/image/<hash>/${local.talos.version}/nocloud-amd64.raw.gz"
  ...
}
```

---

## 🔐 Talos Configuration

- Generates `machine_secrets` using `talos_machine_secrets`
- Uses secrets to generate control plane and worker configuration
- Applies the configuration to the provisioned VMs
- Bootstraps the control plane

---

## ✅ Cluster Health & Kubeconfig

Once the cluster is bootstrapped, health is validated and `kubeconfig` is retrieved:

```hcl
output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
```

---

## 🚀 Usage

1. Replace placeholder MAC addresses (`mac-of-cp-01`, `mac-of-worker-01`) via GitHub Actions or manually.
2. Run:

```bash
terraform init
terraform apply -auto-approve
```

3. Export and use the kubeconfig to interact with your Talos-managed Kubernetes cluster.

---

## 📜 Outputs

| Name         | Description                          |
|--------------|--------------------------------------|
| `talosconfig`| Talos client configuration (base64)  |
| `kubeconfig` | Kubernetes config for the cluster    |

---

## 🛡️ Security Notes

- Outputs are marked `sensitive` to avoid accidental exposure.
- MAC addresses should be passed securely (e.g., GitHub Secrets).


---
