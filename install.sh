#!/bin/bash

DIRPATH=$(dirname ${0})

if [ "$EUID" -eq 0 ]
then
    USERHOME=$(getent passwd $SUDO_USER | cut -d: -f6)
elif [ "${1}" == "-f" ]
then
    USERHOME=$HOME
else
    echo "Please run as root or use -f"
    exit
fi

echo $DIRPATH
echo $USERHOME

#apt-get install tmux
#cp $DIRPATH/srcs/tmux.conf $HOME/.tmux.conf
#cp $DIRPATH/srcs/vimrc $HOME/.vimrc
