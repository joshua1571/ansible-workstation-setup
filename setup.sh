#!/usr/bin/env bash

set -euo pipefail

echo "Update and Upgrade packages before starting"
sudo dnf update && sudo dnf upgrade

echo "Install ansible and ansible-lint"
sudo dnf install python3 ansible ansible-lint

echo "Verify that ansible was installed"
which ansible-playbook