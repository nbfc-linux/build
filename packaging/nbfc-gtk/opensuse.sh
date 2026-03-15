#!/bin/bash

FPM=fpm.ruby4.0
DEST_DIR=/tmp/nbfc-gtk.build

set -e

cd "$(dirname "$0")"

grep -i suse /etc/os-release || {
  echo "Not on Open Suse";
  exit 1
}

zypper -n --gpg-auto-import-keys install --no-recommends \
  git \
  make \
  python3 \
  ruby \
  rpmbuild

export PATH="$HOME/.local/share/gem/ruby/4.0.0/bin/:$PATH"

type $FPM || {
  gem install --user-install fpm
}

rm -rf nbfc-gtk

git clone https://github.com/nbfc-linux/nbfc-gtk

cd nbfc-gtk

VERSION=$(cat VERSION)

make

make DESTDIR="$DEST_DIR" install

$FPM -s dir -t rpm \
  -n nbfc-gtk \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "GUI for NBFC-Linux (gtk-based)" \
  --url "https://github.com/nbfc-linux/nbfc-gtk" \
  --prefix / \
  --depends "python3-gobject" \
  --depends "gtk4" \
  --depends "gtk4-devel" \
  -C "$DEST_DIR" \
  usr
