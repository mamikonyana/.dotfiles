#!/bin/zsh

USAGE="
Usage: `basename $0` [--update]
"
install_xmonad=false

while [ "$1" != "" ]; do
    case "$1"  in
        --xmonad )
            install_xmonad=true
            ;;
        * )
            echo $USAGE
            exit 1
    esac
    shift
done

function setup_X
{
    cp ./defaults/.xinitrc ~/
    cp ./defaults/.Xdefaults ~/ 
}

function setup_xmonad
{
    setup_X
    sudo apt-get install xmonad dmenu xmobar
    mkdir ~/.xmonad
    cp ./defaults/xmonad.hs ~/.xmonad/
    cp ./defaults/.dmenurc ~/
    cp ./defaults/.xmobarrc ~/
    echo "installing xmonad"
}

if $install_xmonad ; then
    setup_xmonad
fi

