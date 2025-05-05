#!/bin/bash

echo "NOT READY YET!"
exit 1

DEST_DIR=/tmp/nbfc-linux.build

set -e

cd "$(dirname "$0")"

grep -i "arch linux" /etc/os-release || {
  echo "Not on Arch Linux";
  exit 1
}

type ruby || {
  pacman -S --noconfirm ruby
}

type autoreconf || {
  pacman -S --noconfirm autoconf
}

type make || {
  pacman -S --noconfirm make
}

type git || {
  pacman -S --noconfirm git
}

type python3 || {
  pacman -S --noconfirm python
}

[[ -d "/usr/include/curl" ]] || {
  pacman -S --noconfirm curl
}

[[ -d "/usr/include/openssl" ]] || {
  pacman -S --noconfirm openssl
}

export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin/:$PATH"

type fpm || {
  gem install --user-install fpm
}

rm -rf nbfc-linux

git clone https://github.com/nbfc-linux/nbfc-linux

cd nbfc-linux

cd pkgbuilds

cd nbfc-linux-git

makepkg

# 
# VERSION=$(grep AC_INIT ./configure.ac  | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
# 
# ./autogen.sh
# 
# ./configure --sysconfdir=/etc --prefix=/usr --bindir=/usr/bin
# 
# make
# 
# make DESTDIR="$DEST_DIR" install
# 
# fpm -s dir -t deb \
#   -n nbfc-linux \
#   -v "$VERSION" \
#   --license "GPLv3" \
#   --maintainer "Benjamin Abendroth (braph93@gmx.de)" \
#   --description "NoteBook FanControl ported to Linux" \
#   --url "https://github.com/nbfc-linux/nbfc-linux" \
#   --depends "libcurl4" \
#   --prefix / \
#   -C "$DEST_DIR" \
#   usr etc
