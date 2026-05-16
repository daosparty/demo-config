#!/bin/bash

set -e

LOG="/var/log/daos/democonfig.log"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Define home folders
DISTRO_HOME="/home/daos"
MY_HOME="/home/da"

mkdir -p /workspaces
mkdir -p /mnt/p1

echo "1" > "$LOG"

# relocate my daily scripts
PER_SRC="/tmp/dainit/daspaces"
PER_DEST="$DISTRO_HOME"

if [ -d "$PER_SRC" ]; then
    cp -fr "$PER_SRC"/. "$PER_DEST"/
else
    echo "Directory does not exist: $PER_SRC" >> "$LOG"
fi

{
GITCONFIG="$MY_HOME/.gitconfig"
cat > "$GITCONFIG" <<EOF
[user]
    name = daos
    email = daos@dage.party
EOF
chmod 644 "$GITCONFIG"
} || true

echo "2" >> "$LOG"

cd "$DISTRO_HOME"
mkdir -p "runCommand"

{
cp "$SCRIPT_DIR/i3/launcher" "$DISTRO_HOME/.i3/"
chmod +x "$DISTRO_HOME/.i3/"*
} || true

if [ -d "$SCRIPT_DIR/ffprofile" ]; then
    mkdir -p "$DISTRO_HOME/.config"
    mv "$SCRIPT_DIR/ffprofile" "$DISTRO_HOME/.config/"
fi

{
cp "$SCRIPT_DIR/runCommand/"* "$DISTRO_HOME/runCommand/"
chmod +x "$DISTRO_HOME/runCommand/"*

cat > "$DISTRO_HOME/runCommand/.bashrc" <<EOF
export PATH=\$PATH:$DISTRO_HOME/runCommand
EOF
} || true

{
grep -qxF "source $DISTRO_HOME/runCommand/.bashrc" "$MY_HOME/.bashrc" || \
echo "source $DISTRO_HOME/runCommand/.bashrc" >> "$MY_HOME/.bashrc"
} || true

{
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz
} || true

chown -R 1000:1000 "$DISTRO_HOME"/
chown -R 1000:1000 "$MY_HOME"/


apt install -y git curl xclip ripgrep fd-find

if git clone --depth=1 https://github.com/LazyVim/starter "$MY_HOME/.config/nvim"; then
    rm -rf "$MY_HOME/.config/nvim/.git"
    chown -R 1000:1000 "$MY_HOME/.config"
else
    echo "nvim config clone error" >> "$LOG"
fi


echo "3" >> "$LOG"

# install chinese font
{
curl -LO https://raw.githubusercontent.com/daosparty/fonts/refs/heads/master/wqy/wqy-microhei.ttc
mkdir -p /usr/share/fonts/truetype/wqy
mv  wqy-microhei.ttc /usr/share/fonts/truetype/wqy/
} || echo "font install error" >> "$LOG"

# install firefox, if it's not exists
{
DEST="/tmp/daspaces/software/firefox"
if [ ! -x "$DEST/firefox" ]; then
    cd "$DISTRO_HOME"
    mkdir firefox
    cd firefox
    curl -LO https://raw.githubusercontent.com/daosparty/app-firefox-115/refs/heads/master/ff1
    curl -LO https://raw.githubusercontent.com/daosparty/app-firefox-115/refs/heads/master/ff2
    cat ff1 ff2 > firefox.tar.bz2
    
    rm -rf "$DEST" || true
    mkdir -p "$DEST"
    tar -xjf "firefox.tar.bz2" -C "$DEST" --strip-components=1
    
    if [ -x "$DEST/firefox" ]; then
        echo "✔ Firefox binary found and executable" >> "$LOG"
        chown -R 1000:1000 "/tmp/daspaces"
    else
        echo "✘ Error: firefox binary not found in $DEST" >> "$LOG"
    fi
fi
} || echo "firefox install error" >> "$LOG"

cd "$DISTRO_HOME"
if [ -d "firefox" ]; then
    rm -fr firefox
fi


echo "4" >> "$LOG"
