mkdir -p ~/.vim/autoload ~/.vim/bundle; \
curl -so ~/.vim/autoload/pathogen.vim \
    https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim

cd ~/.vim/bundle
git clone https://github.com/scrooloose/syntastic.git

sudo pip install flake8

rm ~/.vimrc
ln -s ~/.vim/vimrc ~/.vimrc

cat > ~/.vim/vimrc <<'_EOF'
" Use pathogen to easily modify the runtime path to include all
" plugins under the ~/.vim/bundle directory
call pathogen#helptags()
call pathogen#infect('bundle/{}')

colorscheme delek
syntax enable

set autoindent

" Get rid of menu and tool bars
set guioptions-=m
set guioptions-=T

" Syntastic checks
let g:syntastic_enable_signs=0
let g:syntastic_python_checkers=['flake8', 'pyflakes']
" Ignore following errors:
" E111 indentation is not a multiple of four
" E121 continuation line indentation is not a multiple of four
let g:syntastic_python_flake8_args="--ignore E111,E121"

" Enable Mouse usage
set mouse=a

" Replace tabs with spaces
set expandtab

set tabstop=2
set shiftwidth=2

" Use strong encryption
set cm=blowfish

" Spellcheck
set spell spelllang=en_us

" Highlight search results
set hlsearch

set autowrite

nnoremap ; :

" Automatically remove trailing whitespaces
" Currently causes 'press enter to continue' when opening the file first time.
" autocmd BufWritePost *.py:%s/\s\+$//e

" Temporary untill get used to key navigation
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Clear highlighted search by ,/
nmap <silent> ,/ :nohlsearch<CR>

" Save if need root access to do so (even after opening as normal user)
cmap w!! w !sudo tee % >/dev/null

_EOF

