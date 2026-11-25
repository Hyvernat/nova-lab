# Makefile : reconstruction de bout en bout du laboratoire NOVA (TP15)
# Usage, sur ctrl : cd /vagrant && make all
# Le préfixe ">" remplace la tabulation obligatoire de make (évite les erreurs de copier-coller)
.RECIPEPREFIX = >
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.PHONY: all deps lint keys cluster harden deploy audit

ANSIBLE_DIR := /vagrant/ansible
SECRETS_DIR := /vagrant/.secrets
PLAYBOOK    := cd $(ANSIBLE_DIR) && ansible-playbook

all: deps lint keys cluster harden deploy audit

# Collections Ansible
deps:
> cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml

# Qualité : YAML, syntaxe des playbooks, bonnes pratiques Ansible
lint:
> cd /vagrant && yamllint ansible
> cd $(ANSIBLE_DIR) && for p in playbooks/*.yml; do ansible-playbook --syntax-check "$$p"; done
> cd $(ANSIBLE_DIR) && ansible-lint playbooks/

# Secrets hors dépôt : mots de passe Vault et clés des exploitants
keys:
> test -d $(SECRETS_DIR)/.vault || { echo "ERREUR : copier les secrets dans $(SECRETS_DIR)"; exit 1; }
> install -d -m 700 /home/vagrant/.vault
> install -m 600 $(SECRETS_DIR)/.vault/preprod $(SECRETS_DIR)/.vault/prod /home/vagrant/.vault/
> install -m 600 $(SECRETS_DIR)/alice $(SECRETS_DIR)/bob /home/vagrant/.ssh/
> install -m 644 $(SECRETS_DIR)/alice.pub $(SECRETS_DIR)/bob.pub /home/vagrant/.ssh/

# Socle commun, k3s et Helm
cluster:
> $(PLAYBOOK) playbooks/baseline.yml
> $(PLAYBOOK) playbooks/cluster.yml

# Comptes nominatifs puis durcissement CIS/ANSSI
harden:
> $(PLAYBOOK) playbooks/harden.yml

# Déploiement preprod puis prod, sans pause interactive
deploy:
> $(PLAYBOOK) playbooks/deploy.yml -e nova_require_approval=false

# Audit de conformité Goss sur les deux environnements
audit:
> $(PLAYBOOK) playbooks/audit.yml