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
mkdir -p "$MY_HOME/.config/labwc"
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

##### .runCommand section
{
if [ -d "$DISTRO_HOME/.runCommand" ]; then
    if [ -d "$DISTRO_HOME/runCommand" ]; then
        cp -a "$DISTRO_HOME/runCommand/." "$DISTRO_HOME/.runCommand/"
        rm -fr "$DISTRO_HOME/runCommand/"
    fi
else
    if [ -d "$DISTRO_HOME/runCommand" ]; then
        mv "$DISTRO_HOME/runCommand" "$DISTRO_HOME/.runCommand"
    else
        mkdir -p "$DISTRO_HOME/.runCommand"
    fi
fi

cp -a "$SCRIPT_DIR/runCommand/." "$DISTRO_HOME/.runCommand/"
chmod +x "$DISTRO_HOME/.runCommand/"*

cat > "$DISTRO_HOME/.runCommand/.bashrc" <<EOF
export PATH=\$PATH:$DISTRO_HOME/.runCommand
cd /home/daos
EOF

} || echo "runCommand combine error" >> "$LOG"

{
grep -qxF "source $DISTRO_HOME/.runCommand/.bashrc" "$MY_HOME/.bashrc" || \
echo "source $DISTRO_HOME/.runCommand/.bashrc" >> "$MY_HOME/.bashrc"
} || true

mkdir -p "$DISTRO_HOME/.software"
mkdir -p "$DISTRO_HOME/.udff"

chown -R 1000:1000 "$DISTRO_HOME"/
chown -R 1000:1000 "$MY_HOME"/

echo "3" >> "$LOG"

# souonds hardware fix
{
tee /etc/asound.conf << 'EOF'
defaults.pcm.card 0
defaults.ctl.card 0

pcm.!default {
    type hw
    card 0
}

ctl.!default {
    type hw
    card 0
}
EOF

sudo alsa force-reload

amixer set Master 80% unmute     2>/dev/null
amixer set PCM 85% unmute        2>/dev/null
amixer set Speaker 85% unmute    2>/dev/null
amixer set Headphone 85% unmute  2>/dev/null
amixer set 'Headset' 85% unmute  2>/dev/null
} || echo "souonds config error" >> "$LOG"


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
# DEST2="/tmp/daspaces/software/firefox"
if [ ! -x "$DEST/firefox" ]; then
    cd "$DISTRO_HOME"
    mkdir -p firefox
    cd firefox
    curl -fLO https://raw.githubusercontent.com/daosparty/app-firefox-115/refs/heads/master/ff1
    curl -fLO https://raw.githubusercontent.com/daosparty/app-firefox-115/refs/heads/master/ff2
    cat ff1 ff2 > firefox.tar.bz2
    
    rm -rf "$DEST" || true
    mkdir -p "$DEST"
    tar -xjf "firefox.tar.bz2" -C "$DEST" --strip-components=1
    
    if [ -x "$DEST/firefox" ]; then
        echo "✔ Firefox binary found and executable" >> "$LOG"
        # mkdir -p "$DEST2"
        # cp -fr "$DEST"/. "$DEST2"/
        # chown -R 1000:1000 "/tmp/daspaces"
    else
        echo "✘ Error: firefox binary not found in $DEST" >> "$LOG"
    fi
fi
} || echo "firefox install error" >> "$LOG"

if [ -d "$DISTRO_HOME/firefox" ]; then
    rm -rf "$DISTRO_HOME/firefox"
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
