#!/bin/bash

if [ "$EUID" -ne 0 ] && [ "${1}" != "-f" ]
  then echo "Please run as root or use -f"
  exit
fi

DIRPATH=$(dirname ${0})
USERHOME=~username


#apt-get install tmux
#cp $DIRPATH/srcs/tmux.conf $HOME/.tmux.conf
#cp $DIRPATH/srcs/vimrc $HOME/.vimrc
echo $USERHOME
echo ~username
