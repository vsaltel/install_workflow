#!/bin/bash

DIRPATH=$(dirname ${0})
LOGFILE="${DIRPATH}/logs"

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

echo "GCC INSTALL"
apt-get -y install gcc >> $LOGFILE
echo "MAKE INSTALL"
apt-get -y install make >> $LOGFILE
echo "CURL INSTALL"
apt-get -y install curl >> $LOGFILE
echo "GIT INSTALL"
apt-get -y install git >> $LOGFILE
echo "VIM INSTALL"
apt-get -y install vim >> $LOGFILE
echo "TMUX INSTALL"
apt-get -y install tmux >> $LOGFILE

echo "COPY CONFIG FILES"
cp $DIRPATH/srcs/tmux.conf $USERHOME/.tmux.conf
cp $DIRPATH/srcs/vimrc $USERHOME/.vimrc

#A retirer si colors s'applique tout seul
#cp -R $DIRPATH/srcs/vim $USERHOME/.vim

echo "INSTALL VIM PLUGINS"
