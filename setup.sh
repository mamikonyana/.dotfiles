#!/bin/sh
cp zshrc_template ~/.zshrc
# TODO(arsen): only works on Linux
sed -i "s+___BASE_DIRECTORY___+`pwd`+g" ~/.zshrc

