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

echo "Installing CLI tools..."
dnf5 install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || true


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
  yazi \
  resvg \
  wl-clipboard

systemctl enable podman.socket

echo "CLI tools installation complete"
