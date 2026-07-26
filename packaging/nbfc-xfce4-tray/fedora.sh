#!/bin/bash

DEST_DIR=/tmp/nbfc-xfce4-tray.build

set -e

cd "$(dirname "$0")"

cat /etc/fedora-release || {
  echo "Not on fedora";
  exit 1
}

dnf install -y \
  git \
  gcc \
  ruby \
  rpmbuild

dnf install -y --setopt=install_weak_deps=False \
  meson \
  gtk3-devel \
  xfce4-panel-devel

export PATH="$HOME/.local/share/gem/ruby/bin/:$PATH"

type fpm || {
  gem install --user-install fpm
}

rm -rf nbfc-xfce4-tray

git clone https://github.com/nbfc-linux/nbfc-xfce4-tray

cd nbfc-xfce4-tray

VERSION=$(cat VERSION)

meson setup build --prefix=/usr
meson compile -C build
DESTDIR="$DEST_DIR" meson install -C build

fpm -s dir -t rpm \
  -n nbfc-xfce4-tray  \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "XFCE4 Panel Plugin for NBFC-Linux" \
  --url "https://github.com/nbfc-linux/nbfc-xfce4-tray" \
  --depends "xfce4-panel" \
  --prefix / \
  -C "$DEST_DIR" \
  usr
