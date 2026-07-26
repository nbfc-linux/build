#!/bin/bash

DEST_DIR=/tmp/nbfc-xfce4-tray.build

set -e

cd "$(dirname "$0")"

cat /etc/debian_version || {
  echo "Not on debian";
  exit 1
}

apt update

apt install -y \
  git \
  gcc \
  meson \
  libgtk-3-dev \
  libxfce4ui-2-dev \
  libxfce4panel-2.0-dev \
  ruby

export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin/:$PATH" # debian trixie
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin/:$PATH" # ubuntu noble
export PATH="$HOME/.local/share/gem/ruby/3.1.0/bin/:$PATH" # debian bookworm
export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin/:$PATH" # ubuntu jammy

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

fpm -s dir -t deb \
  -n nbfc-xfce4-tray \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "XFCE4 Panel Plugin for NBFC-Linux" \
  --url "https://github.com/nbfc-linux/nbfc-xfce4-tray" \
  --depends libxfce4panel-2.0-4 \
  --depends xfce4-panel \
  --prefix / \
  -C "$DEST_DIR" \
  usr
