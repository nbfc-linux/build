#!/bin/bash

set -e

cd "$(dirname "$0")"

rm -rf nbfc-qt
rm -rf nbfc-gtk
rm -rf nbfc-linux

# =============================================================================
# NBFC-Qt
# =============================================================================

git clone https://github.com/nbfc-linux/nbfc-qt

pushd nbfc-qt/pkgbuilds/nbfc-qt-git

makepkg

sudo cp *.pkg.tar.zst /tmp/packages/nbfc-qt

popd

# =============================================================================
# NBFC-Gtk
# =============================================================================

git clone https://github.com/nbfc-linux/nbfc-gtk

pushd nbfc-gtk/pkgbuilds/nbfc-gtk-git

makepkg

sudo cp *.pkg.tar.zst /tmp/packages/nbfc-gtk

popd

# =============================================================================
# NBFC-Linux
# =============================================================================

git clone https://github.com/nbfc-linux/nbfc-linux

pushd nbfc-linux/pkgbuilds/nbfc-linux-git

makepkg

PACKAGE=$(ls | grep pkg.tar.zst | grep -v debug)
sudo cp "$PACKAGE" /tmp/packages/nbfc-linux

popd

# =============================================================================
# Cleanup
# =============================================================================

rm -rf nbfc-qt
rm -rf nbfc-gtk
rm -rf nbfc-linux
