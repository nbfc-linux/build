#!/bin/bash

CHROOT_DIR=/tmp/fedora.nbfc-linux
CACHE_DIR=/tmp/fedora.cache
REPOS_DIR=/tmp/fedora.repos
RELEASE=42

set -e

echo "This will install fedora '$RELEASE' into $CHROOT_DIR"
echo "Press enter to continue"
read

# Install debootstrap
yay -S --needed dnf

# Make chroot dir
sudo mkdir -p "$CHROOT_DIR"

# Make repos and cache dir
mkdir -p "$REPOS_DIR" "$CACHE_DIR"

# Copy repo file
cp ./fedora.repo "$REPOS_DIR"

# Install fedora into chroot
sudo dnf \
  --setopt=reposdir="$REPOS_DIR" \
  --setopt=cachedir="$CACHE_DIR" \
  --releasever=$RELEASE \
  --installroot="$CHROOT_DIR" \
  --nogpgcheck \
  install @core
