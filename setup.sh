#!/usr/bin/env bash

set -euo pipefail

echo "Detecting operating system..."

# Load OS information
source /etc/os-release

case "$ID" in
    ubuntu)
        echo "Ubuntu detected."
        echo "Updating and upgrading packages..."
        sudo apt update
        sudo apt upgrade -y

        echo "Installing Ansible and ansible-lint..."
        sudo apt install -y ansible ansible-lint
        ;;

    fedora)
        echo "Fedora detected."
        echo "Updating and upgrading packages..."
        sudo dnf upgrade --refresh -y

        echo "Installing Ansible and ansible-lint..."
        sudo dnf install -y ansible ansible-lint
        ;;

    *)
        echo "Unsupported operating system: $ID"
        exit 1
        ;;
esac

echo "Verifying Ansible installation..."

if command -v ansible-playbook >/dev/null 2>&1; then
    echo "Ansible installed successfully:"
    ansible-playbook --version
else
    echo "Error: ansible-playbook was not found."
    exit 1
fi

if command -v ansible-lint >/dev/null 2>&1; then
    echo "ansible-lint installed successfully:"
    ansible-lint --version
else
    echo "Error: ansible-lint was not found."
    exit 1
fi

echo "Installation complete."
