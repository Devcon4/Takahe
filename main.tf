terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 1.12" # Use the latest appropriate version
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.5" # Use the latest appropriate version
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "lxd" {
  # Configure LXD provider connection if needed (e.g., remote LXD)
  # Defaults to local unix socket
}

# Define variables for cluster configuration
variable "cluster_name" {
  description = "Name for the Talos cluster"
  type        = string
  default     = "talos-lxd"
}

variable "talos_version" {
  description = "Talos version to use"
  type        = string
  default     = "v1.7.5" # Specify desired Talos version
}

variable "kubernetes_version" {
  description = "Kubernetes version for Talos"
  type        = string
  default     = "1.30.0" # Specify desired K8s version compatible with Talos version
}

variable "controlplane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "lxd_image" {
  description = "LXD image to use for Talos nodes"
  type        = string
  default     = "images:ubuntu/22.04/cloud" # Example, ensure it's compatible
}

variable "controlplane_memory" {
  description = "Memory for control plane nodes (e.g., '2GB')"
  type        = string
  default     = "2GB"
}

variable "controlplane_vcpu" {
  description = "vCPUs for control plane nodes"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory for worker nodes (e.g., '4GB')"
  type        = string
  default     = "4GB"
}

variable "worker_vcpu" {
  description = "vCPUs for worker nodes"
  type        = number
  default     = 2
}

# LXD Profile for Talos Nodes
resource "lxd_profile" "talos_node" {
  name = "${var.cluster_name}-profile"

  config = {
    # Required for running containers within the VM (e.g., Kubernetes pods)
    "security.nesting"      = "true"
    # Required by Talos/Kubernetes components
    "security.syscalls.intercept.mknod"  = "true"
    "security.syscalls.intercept.setxattr" = "true"
    # Required for Kata containers or similar runtimes if used
    "linux.kernel_modules" = "ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter"
    # Cloud-init configuration
    "user.user-data" = <<-EOF
      #cloud-config
      runcmd:
        - [ sh, -c, "until ping -c1 google.com; do sleep 1; done" ] # Wait for network
      # Talos installation commands will be added dynamically later
    EOF
  }

  device {
    name = "root"
    type = "disk"
    path = "/"
    pool = "default" # Replace with your LXD storage pool name if different
  }

  device {
    name = "eth0"
    type = "nic"
    nictype = "bridged"
    parent = "lxdbr0" # Replace with your LXD bridge name if different
  }

  # Add more devices if needed (e.g., specific storage)
}

# Placeholder for Kustomize manifest generation
resource "null_resource" "kustomize_build" {
  # This will be configured later to run kustomize build
  triggers = {
    # Re-run when kustomization files change (requires listing them)
    kustomization_yaml = timestamp() # Simple trigger for now
  }

  provisioner "local-exec" {
    command = "echo 'Kustomize build step placeholder'"
    # Actual command: kustomize build kustomize/overlays/lxd > generated-manifests.yaml
  }
}

# Placeholder for reading generated manifests
data "local_file" "kustomize_manifests" {
  # Depends on the kustomize build step completing
  depends_on = [null_resource.kustomize_build]
  filename = "generated-manifests.yaml" # The output file from kustomize build
  # Add error handling if file doesn't exist? Terraform will fail if it doesn't.
}


# --- Talos Configuration (Placeholders - requires Talos provider resources) ---
# Example structure - details depend on Talos provider usage

# resource "talos_machine_configuration" "controlplane" { ... }
# resource "talos_machine_configuration" "worker" { ... }
# resource "talos_client_configuration" "talosconfig" { ... }


# --- LXD Instance Creation (Placeholders) ---
# Example structure - details depend on Talos provider integration or manual cloud-init

# resource "lxd_instance" "controlplane" {
#   count = var.controlplane_count
#   ...
#   profiles = [lxd_profile.talos_node.name]
#   user_data = # Inject generated talos_machine_configuration content here
# }

# resource "lxd_instance" "worker" {
#   count = var.worker_count
#   ...
#   profiles = [lxd_profile.talos_node.name]
#   user_data = # Inject generated talos_machine_configuration content here
# }

# --- Talos Bootstrap (Placeholder) ---
# Example structure

# resource "talos_machine_bootstrap" "bootstrap" { ... }
