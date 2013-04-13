#!/bin/zsh
cp .zshrc_template ~/.zshrc
# TODO(arsen): only works on Linux
sed -i "s+___BASE_DIRECTORY___+`pwd`+g" ~/.zshrc

for script in ./small_scripts/*sh; do
  echo "alias $(grep '#short-name: ' $script | sed 's+#short-name: ++')='$(pwd)/$script'" >> ~/.zshrc
done
