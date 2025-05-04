#!/bin/bash

ARCH=amd64
CHROOT_DIR=/tmp/ubuntu.nbfc-linux
RELEASE=jammy

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install debootstrap
pacman -S --needed debootstrap

# Make chroot dir
mkdir -p "$CHROOT_DIR"

# Install debian into chroot
debootstrap --arch=$ARCH $RELEASE "$CHROOT_DIR" http://archive.ubuntu.com/ubuntu
