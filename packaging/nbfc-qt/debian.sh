#!/bin/bash

DEST_DIR=/tmp/nbfc-qt.build

set -e

cd "$(dirname "$0")"

cat /etc/debian_version || {
  echo "Not on debian";
  exit 1
}

apt update

apt install -y \
  git \
  make \
  python3 \
  ruby \
  binutils

export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin/:$PATH"

type fpm || {
  gem install --user-install fpm
}

rm -rf nbfc-qt

git clone https://github.com/nbfc-linux/nbfc-qt

cd nbfc-qt

VERSION=$(cat VERSION)

make

make DESTDIR="$DEST_DIR" install

fpm -s dir -t deb \
  -n nbfc-qt \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "GUI for NBFC-Linux (qt-based)" \
  --url "https://github.com/nbfc-linux/nbfc-qt" \
  --depends "python3-pyqt6 | python3-pyqt5" \
  --prefix / \
  -C "$DEST_DIR" \
  usr
