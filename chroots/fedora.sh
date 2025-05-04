#!/bin/bash

CHROOT_DIR=/tmp/fedora.nbfc-linux
CACHE_DIR=/tmp/fedora.cache
REPOS_DIR=/tmp/fedora.repos
RELEASE=42

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

cd "$(dirname "$0")"

# Install dnf
pacman -S --needed dnf

# Make chroot dir
mkdir -p "$CHROOT_DIR"

# Make repos and cache dir
mkdir -p "$REPOS_DIR" "$CACHE_DIR"

# Copy repo file
cp ./fedora.repo "$REPOS_DIR"

# Install fedora into chroot
dnf \
  --setopt=reposdir="$REPOS_DIR" \
  --setopt=cachedir="$CACHE_DIR" \
  --releasever=$RELEASE \
  --installroot="$CHROOT_DIR" \
  --nogpgcheck \
  install @core
