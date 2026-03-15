#!/bin/bash

FPM=fpm.ruby4.0
DEST_DIR=/tmp/nbfc-linux.build

set -e

cd "$(dirname "$0")"

grep -i suse /etc/os-release || {
  echo "Not on Open Suse";
  exit 1
}

zypper -n --gpg-auto-import-keys install --no-recommends \
  git \
  automake \
  autoconf \
  gcc \
  libcurl-devel \
  ruby \
  rpmbuild

export PATH="$HOME/.local/share/gem/ruby/4.0.0/bin/:$PATH"

type $FPM || {
  gem install --user-install fpm
}

rm -rf nbfc-linux

git clone https://github.com/nbfc-linux/nbfc-linux

cd nbfc-linux

VERSION=$(grep AC_INIT ./configure.ac | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

./autogen.sh

./configure --sysconfdir=/etc --prefix=/usr

make

make DESTDIR="$DEST_DIR" install

$FPM -s dir -t rpm \
  -n nbfc-linux \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "NoteBook FanControl ported to Linux" \
  --url "https://github.com/nbfc-linux/nbfc-linux" \
  --depends "libcurl4" \
  --depends "acpica" \
  --prefix / \
  -C "$DEST_DIR" \
  usr etc bin
