mkdir -p ~/.vim/autoload ~/.vim/bundle; \
curl -so ~/.vim/autoload/pathogen.vim \
    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

cd ~/.vim/bundle
git clone https://github.com/scrooloose/syntastic.git


echo "call pathogen#infect()" > ~/.vim/vimrc

rm ~/.vimrc
ln -s ~/.vim/vimrc ~/.vimrc

cat >> ~/.vim/vimrc <<'_EOF'
colorscheme delek
_EOF

