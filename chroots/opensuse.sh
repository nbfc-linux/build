#!/bin/bash

CHROOT_DIR=/tmp/opensuse.nbfc-linux

set -e

echo "This will install Open Suse '$RELEASE' into $CHROOT_DIR"
echo "Press enter to continue"
read

sudo pacman -S --needed zypper

# Make chroot dir
sudo mkdir -p "$CHROOT_DIR"

sudo zypper --root "$CHROOT_DIR" ar \
  "https://download.opensuse.org/tumbleweed/repo/oss/" \
  tumbleweed-oss

sudo zypper --root "$CHROOT_DIR" refresh

sudo zypper --root "$CHROOT_DIR" install \
  -n \
  openSUSE-release zypper bash coreutils glibc vim less iputils

sudo cp /etc/resolv.conf "$CHROOT_DIR/etc"
