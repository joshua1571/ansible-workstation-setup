### Purpose
I created this playbook to configure a brand new fedora workstation install to configure everything for me.

Tested on Fedora 44 Workstation

### Prerequisites
User should already be created
Internet connectivity is established

### How to Use
1. Clone this repository to the newly created Fedora workstation

2. ``cd`` to the cloned repository

3. Modify ``workstation_user`` and ``workstation_group`` variables in workstation-setup.yml to match your user

4. Run ``./setup.sh`` which will update and upgrade host as well as install ansible

5. Run ``./workstation-setup.yml`` which will configure host

### TODOs

- Add support for remote installation

- Add support for custom username/group

- Add test environment using molecule

- Add github actions for CI

- Add support for multi distribution starting with Ubuntu LTS

- Add yazi configuration and add yazi bash function to cd on quit

- Add bash customization (aliases, functions, environment variables)