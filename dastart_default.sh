#!/bin/sh

set -e

LOG="/var/log/daos/democonfig.log"

echo "1" > "$LOG"

xset dpms 60 60 60
modprobe fuse || echo "fuse failed" >> "$LOG"

echo "2" >> "$LOG"

apt install -y git curl xclip ripgrep fd-find

# download neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod +x nvim-linux-x86_64.appimage

mv nvim-linux-x86_64.appimage /usr/local/bin/nvim.appimage
ln -sf /usr/local/bin/nvim.appimage /usr/local/bin/nvim

# LazyVim
git clone --depth=1 https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo "3" >> "$LOG"
