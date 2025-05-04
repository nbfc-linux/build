#!/bin/bash

CHROOT_DIR=/tmp/archlinux.nbfc-linux

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install debootstrap
pacman -S --needed arch-install-scripts

# Make chroot dir
mkdir -p "$CHROOT_DIR"

# Install arch in chroot
pacstrap -K "$CHROOT_DIR"  base
