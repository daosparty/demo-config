#!/bin/sh

set -e

LOG="/var/log/daos/democonfig.log"

echo "1" > "$LOG"

modprobe fuse || echo "fuse failed" >> "$LOG"

echo "2" >> "$LOG"

apt install -y git curl xclip ripgrep fd-find

# relocate my daily scripts
PER_SRC="/home/daos/dainit/daspaces"
PER_DEST="/home/daos"

if [ -d "$PER_SRC" ]; then
    cp -fr "$PER_SRC"/. "$PER_DEST"/
else
    echo "Directory does not exist: $PER_SRC" >> "$LOG"
fi

# download neovim
cd /home/daos/
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz

mv nvim-linux-x86_64.appimage /usr/local/bin/nvim.appimage
ln -sf /usr/local/bin/nvim.appimage /usr/local/bin/nvim

# LazyVim
git clone --depth=1 https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo "3" >> "$LOG"
