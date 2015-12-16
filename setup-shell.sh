#!/bin/zsh

INITIALIZE_CONFIG_FILES='non-empty-string'

USAGE="
Usage: `basename $0` [--update]
"
while [ "$1" != "" ]; do
    case "$1" in
        --update )
            INITIALIZE_CONFIG_FILES=
            ;;
        * )
            echo $USAGE
            exit 1
    esac
    shift
done

cp .zshrc_template ~/.zshrc

if [[ "$OSTYPE" == "darwin12.0" ]]; then
    sed -i "" "s+___BASE_DIRECTORY___+`pwd`+g" ~/.zshrc
else
    sed -i "s+___BASE_DIRECTORY___+`pwd`+g" ~/.zshrc
fi

for script in ./small_scripts/*sh; do
  prefix=$(grep '#interactive-shell: ' $script | sed 's+#interactive-shell: ++')
  if [ "$prefix" ]; then
    prefix="$prefix "
  fi
  echo "alias $(grep '#short-name: ' $script | sed 's+#short-name: ++')='$prefix$(pwd)/$script'" >> ~/.zshrc
done

if [ "$INITIALIZE_CONFIG_FILES" ] ; then
  echo 'Copying config files..'
  cp ./colors.template ./colors.config
fi
