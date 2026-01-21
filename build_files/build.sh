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

echo "Installing extra programs..."
dnf5 install -y --skip-unavailable --skip-broken \
  ripgrep \
  fd-find \
  bat \
  direnv \
  zoxide \
  git-delta \
  tealdeer \
  dua-cli \
  neovim \
  eza \
  yazi \
  zed \
  coolercontrol \
  liquidctl

systemctl enable podman.socket
