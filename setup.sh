#!/bin/bash
set -e

# This script sets up the environment for the project by installing necessary dependencies and setting up the virtual environment.
function install_if_not_exists() {
    local cmd=$1
    local install_cmd=$2

    if ! command -v $cmd &> /dev/null; then
        echo "$cmd not found. Installing..."
        eval "sudo $install_cmd"
    else
        echo "$cmd is already installed."
    fi
}

# if no snap installed error out
if ! command -v snap &> /dev/null; then
    echo "snap not found. Snap is required to install dependencies."
    exit 1
fi

install_if_not_exists "curl" "sudo apt install curl"
install_if_not_exists "talosctl" "curl -sL https://talos.dev/install | sh"
install_if_not_exists "opentofu" "snap install --classic opentofu"
install_if_not_exists "kubectl" "snap install kubectl --classic"
install_if_not_exists "lxd" "snap install lxd"

echo "Installing Kustomize..."
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
mv kustomize /usr/local/bin/

echo "Installing talosctl..."
curl -sL https://github.com/siderolabs/talos/releases/latest/download/talosctl-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64 -o /usr/local/bin/talosctl
chmod +x /usr/local/bin/talosctl

echo "Setup complete."

hash -r
