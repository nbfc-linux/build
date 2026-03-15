#!/bin/bash

FPM=fpm.ruby4.0
DEST_DIR=/tmp/nbfc-qt.build

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
  rpm-build

export PATH="$HOME/.local/share/gem/ruby/4.0.0/bin/:$PATH"

type $FPM || {
  gem install --user-install fpm
}

rm -rf nbfc-qt

git clone https://github.com/nbfc-linux/nbfc-qt

cd nbfc-qt

VERSION=$(cat VERSION)

make QT_VERSION=6

make DESTDIR="$DEST_DIR" install

$FPM -s dir -t rpm \
  -n nbfc-qt \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "GUI for NBFC-Linux (qt-based)" \
  --url "https://github.com/nbfc-linux/nbfc-qt" \
  --depends "python3" \
  --depends "python3-PyQt6" \
  --prefix / \
  -C "$DEST_DIR" \
  usr
