xset dpms 60 60 60

sudo apt install neovim git curl xclip
rm -rf ~/.config/nvim
git clone --depth=1 https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

