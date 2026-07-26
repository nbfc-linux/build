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
  meson \
  xfce4-panel

rm -rf nbfc-xfce4-tray

runuser -u nobody -- git clone https://github.com/nbfc-linux/nbfc-xfce4-tray

cd nbfc-xfce4-tray/pkgbuilds/nbfc-xfce4-tray-git

runuser -u nobody -- makepkg -d

PACKAGE=$(ls | grep pkg.tar.zst | grep -v debug)

mkdir -p "$SCRIPT_DIR/nbfc-xfce4-tray"

cp "$PACKAGE" "$SCRIPT_DIR/nbfc-xfce4-tray"
