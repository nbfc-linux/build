#!/bin/bash

FPM=fpm.ruby3.4
DEST_DIR=/tmp/nbfc-linux.build

set -e

cd "$(dirname "$0")"

grep -i suse /etc/os-release || {
  echo "Not on Open Suse";
  exit 1
}

type ruby || {
  zypper -n --gpg-auto-import-keys install --no-recommends ruby
}

type autoreconf || {
  zypper -n --gpg-auto-import-keys install --no-recommends autoconf
}

type aclocal || {
  zypper -n --gpg-auto-import-keys install --no-recommends automake
}

type gcc || {
  zypper -n --gpg-auto-import-keys install --no-recommends gcc
}

type g++ || {
  zypper -n --gpg-auto-import-keys install --no-recommends gcc-c++
}

type git || {
  zypper -n --gpg-auto-import-keys install --no-recommends git
}

type rpmbuild || {
  zypper -n --gpg-auto-import-keys install --no-recommends rpm-build
}

[[ -d "/usr/include/curl" ]] || {
  zypper -n --gpg-auto-import-keys install --no-recommends libcurl-devel
}

#export PATH="$HOME/.gem/ruby/$(ruby -e 'print RUBY_VERSION')/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin/:$PATH"

type $FPM || {
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

$FPM -s dir -t rpm \
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
