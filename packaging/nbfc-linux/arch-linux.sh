#!/bin/bash

set -e

grep -i "arch linux" /etc/os-release || {
  echo "Not on Arch Linux";
  exit 1
}

SCRIPT_DIR="$(realpath "$(dirname "$0")")"

cd /tmp

pacman -Sy

pacman -S --noconfirm --needed \
  git \
  base-devel

rm -rf nbfc-linux

runuser -u nobody -- git clone https://github.com/nbfc-linux/nbfc-linux

cd nbfc-linux/pkgbuilds/nbfc-linux-git

runuser -u nobody -- makepkg -d

PACKAGE=$(ls | grep pkg.tar.zst | grep -v debug)

mkdir -p "$SCRIPT_DIR/nbfc-linux"

cp "$PACKAGE" "$SCRIPT_DIR/nbfc-linux"
