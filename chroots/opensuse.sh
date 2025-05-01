#!/bin/bash

CHROOT_DIR=/tmp/opensuse.nbfc-linux
CACHE_DIR=/tmp/opensuse.cache
REPOS_DIR=/tmp/opensuse.repos
RELEASE=15.5

set -e

echo "This will install Open Suse '$RELEASE' into $CHROOT_DIR"
echo "Press enter to continue"
read

# Install debootstrap
yay -S --needed dnf

# Make chroot dir
sudo mkdir -p "$CHROOT_DIR"

# Make repos and cache dir
mkdir -p "$REPOS_DIR" "$CACHE_DIR"

# Copy repo file
cp ./opensuse.repo "$REPOS_DIR"

# Install opensuse into chroot
sudo dnf \
  --setopt=reposdir="$REPOS_DIR" \
  --setopt=cachedir="$CACHE_DIR" \
  --releasever=$RELEASE \
  --installroot="$CHROOT_DIR" \
  --nogpgcheck \
  install \
  bash coreutils filesystem vim tar gzip shadow \
  zypper openSUSE-release rpm glibc glibc-locale less
