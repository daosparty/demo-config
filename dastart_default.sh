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


GITCONFIG="/home/da/.gitconfig"
cat > "$GITCONFIG" <<EOF
[user]
    name = daos
    email = daos@dage.party
EOF
chmod 644 "$GITCONFIG"
  
# download neovim
cd /home/daos/

cp /home/daos/default/i3/launcher /home/daos/.i3/
chmod +x /home/daos/.i3/*

cp /home/daos/default/runCommand/* /home/daos/runCommand/
chmod +x /home/daos/runCommand/*

echo "source /home/daos/runCommand/.bashrc" >> /home/da/.bashrc

cat > /home/daos/runCommand/.bashrc <<'EOF'
export PATH=$PATH:/home/daos/runCommand
EOF

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz

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


