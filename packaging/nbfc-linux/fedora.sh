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

type autoreconf || {
  dnf install -y autoconf
}

type aclocal || {
  dnf install -y aclocal
}

type gcc || {
  dnf install -y gcc
}

type g++ || {
  dnf install -y g++
}

type git || {
  dnf install -y git
}

type rpmbuild || {
  dnf install -y rpmbuild
}

[[ -d "/usr/include/curl" ]] || {
  dnf install -y libcurl-devel
}

#export PATH="$HOME/.gem/ruby/$(ruby -e 'print RUBY_VERSION')/bin:$PATH"
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
  --prefix / \
  -C "$DEST_DIR" \
  usr etc bin
