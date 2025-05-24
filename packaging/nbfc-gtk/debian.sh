#!/bin/bash

DEST_DIR=/tmp/nbfc-gtk.build

set -e

cd "$(dirname "$0")"

cat /etc/debian_version || {
  echo "Not on debian";
  exit 1
}

type ruby || {
  apt install -y ruby
}

type make || {
  apt install -y make
}

type git || {
  apt install -y git
}

type python3 || {
  apt install -y python3
}

type ar || {
  apt install -y binutils
}

export PATH="$HOME/.local/share/gem/ruby/3.1.0/bin/:$PATH"

type fpm || {
  gem install --user-install fpm
}

rm -rf nbfc-gtk

git clone https://github.com/nbfc-linux/nbfc-gtk

cd nbfc-gtk

VERSION=$(cat VERSION)

make

make DESTDIR="$DEST_DIR" install

fpm -s dir -t deb \
  -n nbfc-gtk \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "GUI for NBFC-Linux (gtk-based)" \
  --url "https://github.com/nbfc-linux/nbfc-gtk" \
  --depends "libgles2" \
  --depends "python3-gi" \
  --depends "gir1.2-gtk-4.0" \
  --prefix / \
  -C "$DEST_DIR" \
  usr
