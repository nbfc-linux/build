#!/bin/bash

DEST_DIR=/tmp/nbfc-linux.build

set -e

cd "$(dirname "$0")"

cat /etc/fedora-release || {
  echo "Not on fedora";
  exit 1
}

dnf install -y \
  git \
  aclocal \
  autoconf \
  gcc \
  libcurl-devel \
  ruby \
  rpmbuild

export PATH="$HOME/.local/share/gem/ruby/bin/:$PATH"

type fpm || {
  gem install --user-install fpm
}

rm -rf nbfc-linux

git clone https://github.com/nbfc-linux/nbfc-linux

cd nbfc-linux

VERSION=$(grep AC_INIT ./configure.ac  | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

./autogen.sh

./configure --sysconfdir=/etc --prefix=/usr

make

make DESTDIR="$DEST_DIR" install

fpm -s dir -t rpm \
  -n nbfc-linux \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "NoteBook FanControl ported to Linux" \
  --url "https://github.com/nbfc-linux/nbfc-linux" \
  --depends "libcurl" \
  --depends "acpica-tools" \
  --prefix / \
  -C "$DEST_DIR" \
  usr etc bin
