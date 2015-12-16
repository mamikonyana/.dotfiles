eval `ssh-agent`
xrandr --output Virtual1 --mode 1680x1050

/usr/bin/xcompmgr &
xrdb -load ~/.Xdefaults

xsetroot -cursor_name top_left_arrow

exec /usr/bin/xmonad
