#!/bin/bash

DEST_DIR=/tmp/nbfc-linux.build

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

rm -rf nbfc-qt

git clone https://github.com/nbfc-linux/nbfc-qt

cd nbfc-qt

VERSION=$(cat VERSION)

make

make DESTDIR="$DEST_DIR" install


fpm -s dir -t rpm \
  -n nbfc-qt \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "GUI for NBFC-Linux (qt-based)" \
  --url "https://github.com/nbfc-linux/nbfc-qt" \
  --depends "python3-qt5" \
  --prefix / \
  -C "$DEST_DIR" \
  usr
