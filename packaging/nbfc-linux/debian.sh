#!/bin/bash

DEST_DIR=/tmp/nbfc-linux.build

set -e

cd "$(dirname "$0")"

cat /etc/debian_version || {
  echo "Not on debian";
  exit 1
}

apt update

apt install -y \
  git \
  autoconf \
  make \
  gcc \
  libcurl4 libcurl4-openssl-dev \
  libssl-dev \
  ruby

export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin/:$PATH"

type fpm || {
  gem install --user-install fpm
}

rm -rf nbfc-linux

git clone https://github.com/nbfc-linux/nbfc-linux

cd nbfc-linux

VERSION=$(grep AC_INIT ./configure.ac  | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

./autogen.sh

./configure --sysconfdir=/etc --prefix=/usr --bindir=/usr/bin

make

make DESTDIR="$DEST_DIR" install

fpm -s dir -t deb \
  -n nbfc-linux \
  -v "$VERSION" \
  --license "GPLv3" \
  --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
  --description "NoteBook FanControl ported to Linux" \
  --url "https://github.com/nbfc-linux/nbfc-linux" \
  --depends "libcurl4" \
  --depends "acpica-tools" \
  --depends "acpi-call" \
  --prefix / \
  -C "$DEST_DIR" \
  usr etc
