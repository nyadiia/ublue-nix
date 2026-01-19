ARG BASE_IMAGE=ghcr.io/ublue-os/bazzite-dx-nvidia:stable

# Stage 1: Builder - Build it87-extras kernel module
FROM ${BASE_IMAGE} AS builder

# Copy MOK keys for module signing
COPY certs/akmods_ublue-nix.priv /tmp/certs/private_key.priv
COPY certs/akmods_ublue-nix.der /tmp/certs/public_key.der

# Install keys to expected location
RUN install -Dm644 /tmp/certs/public_key.der /etc/pki/akmods/certs/public_key.der && \
    install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv

# Copy and run it87 build script
COPY build_files/build-it87.sh /tmp/build-it87.sh
RUN /tmp/build-it87.sh

# Stage 2: Final Image
FROM scratch AS ctx
COPY build_files /

FROM ${BASE_IMAGE}

ARG IMAGE_NAME="${IMAGE_NAME:-ublue-nix}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-nyadiia}"

## Base image uses bazzite-dx variants for developer features
## This includes development tools, containers setup, and optional nvidia drivers

### INSTALL IT87-EXTRAS MODULE
# Copy built module from builder stage
COPY --from=builder /it87-extras.ko.xz /tmp/it87-extras.ko.xz
COPY certs/akmods_ublue-nix.der /tmp/certs/public_key.der

# Install module and configure autoload
COPY build_files/install-it87.sh /tmp/install-it87.sh
RUN /tmp/install-it87.sh

### INSTALL CLI TOOLS AND SETUP
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### COPY CONFIG FILES FOR NEW USERS
COPY --from=ctx /config/.gitconfig /etc/skel/.gitconfig
COPY --from=ctx /config/yazi.toml /etc/skel/.config/yazi/config/yazi.toml
COPY --from=ctx /config/bash-config.sh /etc/skel/.bashrc
COPY --from=ctx /config/zsh-config.sh /etc/skel/.zshrc

### CREATE NIX DIRECTORY
# Optional: for users who want to install nix later
RUN mkdir -p /nix

### CREATE OPT DIRECTORY FOR 1PASSWORD
# Pre-create directory to prevent RPM cpio hardlink failures
RUN mkdir -p /opt/1Password

### LINTING
RUN bootc container lint
