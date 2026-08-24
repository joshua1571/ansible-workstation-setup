SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

PLAYBOOK           ?= playbook.yml
CONVERGE_SKIP_TAGS ?= hostname,services,desktop,flatpak
CONVERGE_USER      ?= $(USER)
CONVERGE_GROUP     ?= $(USER)
IDEMPOTENCE_LOG    ?= /tmp/idempotence.log

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

## Converge twice: the first pass applies, the second must be a no-op.
## Asserting on the first pass is meaningless - a clean host always reports changes.
idempotence:
	@echo "== converge 1/2: apply =="
	$(MAKE) --no-print-directory converge
	@echo "== converge 2/2: verify no changes =="
	$(MAKE) --no-print-directory converge | tee $(IDEMPOTENCE_LOG)
	@grep -Eq 'changed=0.*unreachable=0.*failed=0' $(IDEMPOTENCE_LOG) \
	  || { echo "Playbook is not idempotent: the second converge reported changes (see the tasks marked 'changed' above)"; exit 1; }

run:
	./$(PLAYBOOK)
