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
  base-devel \
  python3 \

rm -rf nbfc-qt

runuser -u nobody -- git clone https://github.com/nbfc-linux/nbfc-qt

cd nbfc-qt/pkgbuilds/nbfc-qt-git

runuser -u nobody -- makepkg -d

PACKAGE=$(ls | grep pkg.tar.zst | grep -v debug)

mkdir -p "$SCRIPT_DIR/nbfc-qt"

cp "$PACKAGE" "$SCRIPT_DIR/nbfc-qt"

