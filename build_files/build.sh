#!/bin/bash

set -ouex pipefail

echo "Adding Terra repository..."
dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

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
