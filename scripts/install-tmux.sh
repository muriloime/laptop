#!/bin/bash

set -e

# TMUX - Build and install from source
# Usage: VERSION=3.6a bash install-tmux.sh
VERSION=${VERSION:-3.6a}

sudo apt-get -y remove tmux
wget "https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz"
tar xf "tmux-${VERSION}.tar.gz"
rm -f "tmux-${VERSION}.tar.gz"
cd "tmux-${VERSION}"
./configure && make && sudo make install
cd -
sudo rm -rf /usr/local/src/tmux-*
sudo mv "tmux-${VERSION}" /usr/local/src
