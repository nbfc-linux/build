#!/bin/bash

RELEASE=15.5
CHROOT_DIR=/tmp/opensuse.nbfc-linux

set -e

echo "This will install Open Suse '$RELEASE' into $CHROOT_DIR"
echo "Press enter to continue"
read

sudo pacman -S --needed zypper

# Make chroot dir
sudo mkdir -p "$CHROOT_DIR"

sudo zypper --root "$CHROOT_DIR" ar \
  "https://download.opensuse.org/distribution/leap/$RELEASE/repo/oss/" \
  openSUSE-oss

sudo zypper --root "$CHROOT_DIR" ar \
  "https://download.opensuse.org/update/leap/$RELEASE/oss/" \
  openSUSE-update

sudo zypper --root "$CHROOT_DIR" refresh

sudo zypper --root "$CHROOT_DIR" install \
  -n \
  --no-recommends \
  openSUSE-release zypper bash coreutils glibc vim less iputils ca-certificates

sudo cp /etc/resolv.conf "$CHROOT_DIR/etc"
