#!/bin/bash

set -e

LOG="/var/log/daos/democonfig.log"

# Define home folders
DISTRO_HOME="/home/daos"
MY_HOME="/home/da"
SCRIPT_DIR="$DISTRO_HOME/default"

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
} || echo "git user config error" >> "$LOG"

echo "2" >> "$LOG"

cd "$DISTRO_HOME"
mkdir -p "runCommand"

{
mkdir -p "$DISTRO_HOME/.config/labwc/"
cp "$SCRIPT_DIR/labwc/launcher" "$DISTRO_HOME/.config/labwc/"
cp "$SCRIPT_DIR/labwc/rc.xml" "$MY_HOME/.config/labwc/rc.xml"
cp "$SCRIPT_DIR/labwc/menu.xml" "$MY_HOME/.config/labwc/menu.xml"
chmod +x "$DISTRO_HOME/.config/labwc/"*
} || echo "labwc config error" >> "$LOG"

{
if [ -d "$SCRIPT_DIR/ffprofile" ]; then
    mkdir -p "$DISTRO_HOME/.config"
    mv "$SCRIPT_DIR/ffprofile" "$DISTRO_HOME/.config/"
fi
} || echo "ffprofile move error" >> "$LOG"

{
cp "$SCRIPT_DIR/runCommand/"* "$DISTRO_HOME/runCommand/"
chmod +x "$DISTRO_HOME/runCommand/"*

cat > "$DISTRO_HOME/runCommand/.bashrc" <<EOF
export PATH=\$PATH:$DISTRO_HOME/runCommand
cd /home/daos
EOF
} || echo "runCommand combine error" >> "$LOG"

{
grep -qxF "source $DISTRO_HOME/runCommand/.bashrc" "$MY_HOME/.bashrc" || \
echo "source $DISTRO_HOME/runCommand/.bashrc" >> "$MY_HOME/.bashrc"
} || true

chown -R 1000:1000 "$DISTRO_HOME"/
chown -R 1000:1000 "$MY_HOME"/

echo "3" >> "$LOG"

# install chinese font
{
curl -LO https://raw.githubusercontent.com/daosparty/fonts/refs/heads/master/wqy/wqy-microhei.ttc
mkdir -p /usr/share/fonts/truetype/wqy
mv  wqy-microhei.ttc /usr/share/fonts/truetype/wqy/
} || echo "font install error" >> "$LOG"

# install firefox, if it's not exists
{
# DEST="/tmp/daspaces/software/firefox"
DEST="$DISTRO_HOME/.software/firefox"
DEST2="/tmp/daspaces/software/firefox"
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
        cp -fr $DEST/* $DEST2/
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

{
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz
} || true

{
    apt install -y git curl xclip ripgrep fd-find
} || echo  "apt install git error" >> "$LOG"

{
if git clone --depth=1 https://github.com/LazyVim/starter "$MY_HOME/.config/nvim"; then
    rm -rf "$MY_HOME/.config/nvim/.git"
    chown -R 1000:1000 "$MY_HOME/.config"
else
    echo "nvim config clone error" >> "$LOG"
fi
} || echo "LazyVim config clone error" >> "$LOG"


chown -R 1000:1000 "$DISTRO_HOME"/
chown -R 1000:1000 "$MY_HOME"/


echo "5" >> "$LOG"
