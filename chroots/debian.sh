#!/bin/bash

ARCH=amd64
CHROOT_DIR=/tmp/debian.nbfc-linux
CACHE_DIR=/tmp/debian.cache
RELEASE=bookworm

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install debootstrap
pacman -S --needed debootstrap

# Make chroot dir
mkdir -p "$CHROOT_DIR"

# Make cache dir
mkdir -p "$CACHE_DIR"

# Install debian into chroot
debootstrap \
  --arch=$ARCH \
  --cache-dir="$CACHE_DIR" \
  $RELEASE "$CHROOT_DIR" http://deb.debian.org/debian
