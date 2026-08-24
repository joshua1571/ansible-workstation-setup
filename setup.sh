#!/usr/bin/env bash
#
# Bootstrap a fresh workstation so playbook.yml can run.
# Everything here must work with no Ansible present.

set -euo pipefail

# shellcheck source=/dev/null
. /etc/os-release

echo "==> Detected ${NAME} ${VERSION_ID} (family: ${ID_LIKE:-$ID})"

case "${ID}" in
  fedora)
    sudo dnf -y upgrade --refresh
    sudo dnf -y install python3 ansible-core ansible-lint yamllint ShellCheck git
    ;;
  ubuntu | debian)
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y install python3 ansible-core ansible-lint yamllint shellcheck git

    # Ubuntu 25.10+ defaults to sudo-rs, which ignores sudo's -p prompt flag.
    # Ansible relies on that flag to detect the password prompt, so become
    # times out. Pull in classic sudo if the archive still carries it.
    # NOTE: Canonical plans to drop this fallback in 26.10.
    if ! command -v sudo-ws >/dev/null 2>&1; then
      sudo apt-get -y install sudo-ws || \
        echo "!! classic sudo unavailable - set a NOPASSWD sudoers rule instead"
    fi
    ;;
  *)
    echo "!! Unsupported distribution: ${ID}" >&2
    exit 1
    ;;
esac

echo "==> Installing Galaxy collections"
ansible-galaxy collection install -r requirements.yml

echo "==> Enabling repo-tracked git hooks"
git config core.hooksPath .githooks

echo "==> Verifying"
command -v ansible-playbook
ansible --version | head -1
