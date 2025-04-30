#!/bin/bash

ARCH=amd64
CHROOT_DIR=/tmp/debian.nbfc-linux
RELEASE=bookworm

set -e

echo "This will install debian '$RELEASE' ($ARCH) into $CHROOT_DIR"
echo "Press enter to continue"
read

# Install debootstrap
pacman -S --needed debootstrap

# Make chroot dir
mkdir -p "$CHROOT_DIR"

# Install debian into chroot
debootstrap --arch=$ARCH $RELEASE "$CHROOT_DIR" http://deb.debian.org/debian
