#!/bin/bash

FPM=fpm.ruby4.0
DEST_DIR=/tmp/nbfc-xfce4-tray.build

set -e

cd "$(dirname "$0")"

grep -i suse /etc/os-release || {
  echo "Not on Open Suse";
  exit 1
}

zypper -n --gpg-auto-import-keys install --no-recommends \
  git \
  gcc \
  meson \
  gtk3-devel \
  xfce4-panel-devel \
  ruby \
  rpmbuild

export PATH="$HOME/.local/share/gem/ruby/4.0.0/bin/:$PATH"

type $FPM || {
  gem install --user-install fpm
}

rm -rf nbfc-xfce4-tray

git clone https://github.com/nbfc-linux/nbfc-xfce4-tray

cd nbfc-xfce4-tray

VERSION=$(cat VERSION)

meson setup build --prefix=/usr
meson compile -C build
DESTDIR="$DEST_DIR" meson install -C build

$FPM -s dir -t rpm \
  -n nbfc-xfce4-tray \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "XFCE4 Panel Plugin for NBFC-Linux" \
  --url "https://github.com/nbfc-linux/nbfc-xfce4-tray" \
  --depends "xfce4-panel" \
  --prefix / \
  -C "$DEST_DIR" \
  usr
