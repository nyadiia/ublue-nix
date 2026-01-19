#!/bin/bash

set -ouex pipefail

echo "Setting up Terra repository..."
if ! dnf5 repolist --all | grep -q '^terra '; then
  echo "Installing Terra repository..."
  curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo -o /etc/yum.repos.d/terra.repo
  dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release || true
fi

echo "Enabling Terra repository..."
dnf5 config-manager setopt terra.enabled=1

echo "Installing 1Password repository..."
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'

echo "Installing extra programs..."
dnf5 install -y --skip-unavailable --skip-broken \
  ripgrep \
  fd-find \
  bat \
  1password \
  1password-cli \
  direnv \
  zoxide \
  git-delta \
  tealdeer \
  dua-cli \
  neovim \
  eza \
  yazi

systemctl enable podman.socket
