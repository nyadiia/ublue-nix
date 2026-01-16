#!/bin/bash

set -ouex pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q 'kernel' --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
KVERSION="$(rpm -q 'kernel' --queryformat '%{VERSION}')"
KRELEASE="$(rpm -q 'kernel' --queryformat '%{RELEASE}')"

echo "Building it87-extras for kernel ${KERNEL}"

# check if kernel-devel is already installed
if rpm -q "kernel-devel-${KERNEL}" > /dev/null 2>&1; then
  echo "kernel-devel already installed for ${KERNEL}"
else
  echo "Installing kernel-devel from repositories..."
  # try to install from repos first (works for bazzite custom kernels)
  dnf -y install "kernel-devel-${KERNEL}" || {
    echo "Trying to download from koji..."
    # fallback to koji for standard fedora kernels
    curl -L -O "https://kojipkgs.fedoraproject.org//packages/kernel/${KVERSION}/${KRELEASE}/${ARCH}/kernel-devel-${KERNEL}.rpm"
    filesize=$(stat -c%s "kernel-devel-${KERNEL}.rpm" 2>/dev/null || echo "0")
    if [[ -f "kernel-devel-${KERNEL}.rpm" ]] && [[ "${filesize}" -gt 1000000 ]]; then
      dnf -y install "kernel-devel-${KERNEL}.rpm"
    else
      echo "Error: Failed to obtain kernel-devel"
      exit 1
    fi
  }
fi

# install build tools
dnf -y group install development-tools

# clone it87 source (use grandpares' fork which has akmod spec files)
git clone https://github.com/grandpares/it87.git
cd it87

# build the module
make TARGET="${KERNEL}" clean
make TARGET="${KERNEL}" modules

# sign the module if keys are available
if [[ -f "/etc/pki/akmods/private/private_key.priv" ]]; then
  echo "Signing module with MOK key..."
  "/usr/src/kernels/${KERNEL}/scripts/sign-file" \
    sha256 \
    /etc/pki/akmods/private/private_key.priv \
    /etc/pki/akmods/certs/public_key.der \
    it87-extras.ko
else
  echo "Warning: No signing key found, module will be unsigned"
fi

# compress the module
xz -C crc32 it87-extras.ko

# verify module is valid
modinfo "it87-extras.ko.xz" > /dev/null || exit 1

# copy to output location
cp it87-extras.ko.xz /it87-extras.ko.xz

echo "it87-extras module built successfully"
