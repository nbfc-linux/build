#!/bin/bash

DEST_DIR=/tmp/nbfc-gtk.build

set -e

cd "$(dirname "$0")"

cat /etc/fedora-release || {
  echo "Not on fedora";
  exit 1
}

type ruby || {
  dnf install -y ruby
}

type make || {
  dnf install -y make
}

type git || {
  dnf install -y git
}

type rpmbuild || {
  dnf install -y rpmbuild
}

export PATH="$HOME/.local/share/gem/ruby/bin/:$PATH"

type fpm || {
  gem install --user-install fpm
}

rm -rf nbfc-gtk

git clone https://github.com/nbfc-linux/nbfc-gtk

cd nbfc-gtk

VERSION=$(cat VERSION)

make

make DESTDIR="$DEST_DIR" install

fpm -s dir -t rpm \
  -n nbfc-gtk \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "GUI for NBFC-Linux (gtk-based)" \
  --url "https://github.com/nbfc-linux/nbfc-gtk" \
  --depends "python3-gobject" \
  --depends "gtk4" \
  --prefix / \
  -C "$DEST_DIR" \
  usr
