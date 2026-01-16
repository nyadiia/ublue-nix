#!/bin/bash

set -ouex pipefail

echo "Enabling Terra repository..."
dnf5 config-manager setopt terra.enabled=1

echo "Installing core CLI tools..."
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
  || true

echo "Attempting to install optional tools..."
dnf5 install -y \
  git-delta \
  tealdeer \
  dua-cli \
  2>/dev/null || echo "Some optional packages not available, skipping..."

echo "Installing tools from Terra repository..."
dnf5 install -y \
  eza \
  yazi \
  || true

systemctl enable podman.socket

echo "CLI tools installation complete"
