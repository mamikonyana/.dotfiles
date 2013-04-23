#!/bin/zsh
#short-name: arcurl

OS="Linux"

function extract_open_arc_differentials {
  if [ $OS = "Linux" ]; then
    git log 2> /dev/null --author=arsen -n 30| grep -Pzo "(Author: .* <$USER@locu.com>)(\n.*){3,11}?(\n    Differential Revision: .*|\n    Reviewed By: [a-z]*)" | grep "Differential Revision:" | grep -Po "(http://phabricator.locu.com/D[0-9]{1,})"
  fi
}

out=`extract_open_arc_differentials`
if [ -n "$out" ]; then
  echo "$out"
fi
