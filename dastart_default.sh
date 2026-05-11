#!/bin/sh

set -e

LOG="/var/log/daos/democonfig.log"

echo "1" > "$LOG"

modprobe fuse || echo "fuse failed" >> "$LOG"

echo "2" >> "$LOG"


# relocate my daily scripts
PER_SRC="/home/daos/dainit/daspaces"
PER_DEST="/home/daos"

if [ -d "$PER_SRC" ]; then
    cp -fr "$PER_SRC"/. "$PER_DEST"/
else
    echo "Directory does not exist: $PER_SRC" >> "$LOG"
fi

{
    /home/daos/installfont.sh
} || true

{
GITCONFIG="/home/da/.gitconfig"
cat > "$GITCONFIG" <<EOF
[user]
    name = daos
    email = daos@dage.party
EOF
chmod 644 "$GITCONFIG"
} || true


cd /home/daos/

{
cp /home/daos/default/i3/launcher /home/daos/.i3/
chmod +x /home/daos/.i3/*
} || true

{
cp /home/daos/default/runCommand/* /home/daos/runCommand/
chmod +x /home/daos/runCommand/*

cat > /home/daos/runCommand/.bashrc <<'EOF'
export PATH=$PATH:/home/daos/runCommand
EOF
} || true

{
grep -qxF 'source /home/daos/runCommand/.bashrc' /home/da/.bashrc || \
echo 'source /home/daos/runCommand/.bashrc' >> /home/da/.bashrc
} || true

{
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz
} || true

chown -R 1000:1000 /home/daos
chown -R 1000:1000 /home/da


apt install -y git curl xclip ripgrep fd-find

if git clone --depth=1 https://github.com/LazyVim/starter /home/da/.config/nvim; then
    rm -rf /home/da/.config/nvim/.git
    chown -R 1000:1000 /home/da/.config
else
    echo "nvim config clone error" >> "$LOG"
fi


echo "3" >> "$LOG"

# install chinese font
{
mkdir wqy
curl -LO https://raw.githubusercontent.com/daosparty/fonts/refs/heads/master/wqy/wqy-microhei.ttc
mv wqy-microhei.ttc wqy
cp wqy /usr/share/fonts/truetype/ -fr
} || echo "font install error" >> "$LOG"


echo "4" >> "$LOG"

