#!/bin/bash

set -ouex pipefail

echo "Enabling Terra repository..."
dnf5 config-manager setopt terra.enabled=1

echo "Installing CLI tools..."
dnf5 install -y \
  ripgrep \
  fd-find \
  bat \
  htop \
  gh \
  zip \
  unzip \
  direnv \
  zoxide \
  git-delta \
  tealdeer \
  dua-cli \
  neovim \
  eza \
  yazi

systemctl enable podman.socket

echo "CLI tools installation complete"
