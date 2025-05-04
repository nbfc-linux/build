#!/bin/bash

FPM=fpm.ruby3.4
DEST_DIR=/tmp/nbfc-qt.build

set -e

cd "$(dirname "$0")"

grep -i suse /etc/os-release || {
  echo "Not on Open Suse";
  exit 1
}

type ruby || {
  zypper -n --gpg-auto-import-keys install --no-recommends ruby
}

type make || {
  zypper -n --gpg-auto-import-keys install --no-recommends make
}

type git || {
  zypper -n --gpg-auto-import-keys install --no-recommends git
}

type rpmbuild || {
  zypper -n --gpg-auto-import-keys install --no-recommends rpm-build
}

export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin/:$PATH"

type $FPM || {
  gem install --user-install fpm
}

rm -rf nbfc-qt

git clone https://github.com/nbfc-linux/nbfc-qt

cd nbfc-qt

VERSION=$(cat VERSION)

make

make DESTDIR="$DEST_DIR" install

$FPM -s dir -t rpm \
  -n nbfc-qt \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "GUI for NBFC-Linux (qt-based)" \
  --url "https://github.com/nbfc-linux/nbfc-qt" \
  --depends "python3-qt5" \
  --prefix / \
  -C "$DEST_DIR" \
  bin
