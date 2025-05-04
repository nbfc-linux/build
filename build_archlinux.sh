#!/bin/bash

set -e

cd "$(dirname "$0")"

rm -rf nbfc-qt
rm -rf nbfc-linux

# =============================================================================
# NBFC-QT
# =============================================================================

git clone https://github.com/nbfc-linux/nbfc-qt

pushd nbfc-qt/pkgbuilds/nbfc-qt-git

makepkg

sudo cp *.pkg.tar.zst /tmp/packages/nbfc-qt

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
rm -rf nbfc-linux
