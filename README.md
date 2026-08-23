### Purpose
I created this playbook to configure a brand new fedora workstation install to configure everything for me.
Tested on Fedora workstation 44

### Prerequisites
User should already be created
Internet connectivity is established

### How to Use
Clone this repository to the newly created Fedora workstation
``cd`` to the cloned repository
Modify ``workstation_user`` and ``workstation_group`` variables in workstation-setup.yml to match your user
Run ``./setup.sh`` which will update and upgrade host as well as install ansible
Run ``./workstation-setup.yml`` which will configure host

### TODOs

- Add support for remote installation

- Add support for custom username/group

- Add test environment using molecule

- Add github actions for CI

- Add support for multi distribution starting with Ubuntu LTS

- Add yazi configuration and add yazi bash function to cd on quit

- Add bash customization (aliases, functions, environment variables)