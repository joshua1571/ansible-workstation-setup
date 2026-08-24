SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

PLAYBOOK           ?= playbook.yml
CONVERGE_SKIP_TAGS ?= hostname,services,desktop,flatpak
CONVERGE_USER      ?= $(USER)
CONVERGE_GROUP     ?= $(USER)

.PHONY: bootstrap deps hooks lint lint-production syntax check converge idempotence run

## Install Galaxy collections (needed by CI and by a fresh clone)
deps:
	ansible-galaxy collection install -r requirements.yml

## Point git at the repo-tracked hooks (local only)
hooks:
	git config core.hooksPath .githooks

bootstrap: deps hooks
	@echo "Ready. Hooks active, collections installed."

lint:
	yamllint --strict .
	shellcheck setup.sh
	ansible-lint --offline

## Advisory: the gap between the enforced profile and `production`
lint-production:
	ansible-lint --offline --profile production

syntax:
	ansible-playbook $(PLAYBOOK) --syntax-check

check: lint syntax

converge:
	ansible-playbook $(PLAYBOOK) --diff \
	  --skip-tags "$(CONVERGE_SKIP_TAGS)" \
	  -e workstation_user=$(CONVERGE_USER) \
	  -e workstation_group=$(CONVERGE_GROUP)

idempotence:
	$(MAKE) converge | tee /tmp/idempotence.log
	grep -q "changed=0.*failed=0" /tmp/idempotence.log \
	  || { echo "Playbook is not idempotent"; exit 1; }

run:
	./$(PLAYBOOK)
