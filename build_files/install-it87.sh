#!/bin/bash

set -ouex pipefail

KERNEL="$(rpm -q 'kernel' --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

echo "Installing it87-extras module for kernel ${KERNEL}"

# create module directory
mkdir -p "/usr/lib/modules/${KERNEL}/extra/it87-extras"

# install the module
cp /tmp/it87-extras.ko.xz "/usr/lib/modules/${KERNEL}/extra/it87-extras/it87-extras.ko.xz"

# update module dependencies
depmod -a "${KERNEL}"

# install public MOK key for user enrollment
install -Dm644 /tmp/certs/public_key.der /etc/pki/akmods/certs/akmods_ublue-nix.der

# configure module to load at boot
echo 'it87-extras' > /usr/lib/modules-load.d/it87-extras.conf

echo "it87-extras module installed successfully"
echo "Users must enroll /etc/pki/akmods/certs/akmods_ublue-nix.der for secure boot"
