#!/bin/bash

CHROOT_DIR=/tmp/opensuse.nbfc-linux

set -e

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Install zypper
pacman -S --needed zypper

# Make chroot dir
mkdir -p "$CHROOT_DIR"

zypper --root "$CHROOT_DIR" ar \
  "https://download.opensuse.org/tumbleweed/repo/oss/" \
  tumbleweed-oss

zypper --root "$CHROOT_DIR" refresh

zypper --root "$CHROOT_DIR" install \
  -n \
  openSUSE-release zypper bash coreutils glibc vim less iputils

cp /etc/resolv.conf "$CHROOT_DIR/etc"
