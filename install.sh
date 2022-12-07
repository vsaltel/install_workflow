#!/bin/bash

DIRPATH=$(dirname ${0})
LOGFILE="${DIRPATH}/logs"

if [ "$EUID" -eq 0 ]; then
    if [ -n "${SUDO_USER}" ]; then
        USERNAME=${SUDO_USER}
    elif [ -n "${1}" ]; then
        USERNAME=${1}
    else
        echo -e "Usage :\n\tsudo ${0}\n\tor\n\t${0} [USER]"
        exit
    fi

    if [ -n ${USERNAME} ]; then
        USERHOME=$(getent passwd ${USERNAME} | cut -d: -f6)
    else
        echo "User not find"
        exit
    fi

    if [ -z ${USERHOME} ]; then
        echo "${USERNAME} not exist on the system"
        exit
    fi
else
    echo "Please run as root"
    exit
fi

echo "APT UPDATE"
apt-get -y update >> $LOGFILE
echo "GCC INSTALL"
apt-get -y install gcc >> $LOGFILE
echo "MAKE INSTALL"
apt-get -y install make >> $LOGFILE
echo "CMAKE INSTALL"
apt-get -y install cmake >> $LOGFILE
echo "CURL INSTALL"
apt-get -y install curl >> $LOGFILE
echo "PYTHON3 INSTALL"
apt-get -y install python3 >> $LOGFILE
echo "PIP3 INSTALL"
apt-get -y install python3-pip >> $LOGFILE
echo "GIT INSTALL"
apt-get -y install git >> $LOGFILE
echo "VIM INSTALL"
apt-get -y install vim >> $LOGFILE
echo "VIM GUI-COMMON INSTALL"
apt-get -y install vim-gui-common >> $LOGFILE
echo "VIM RUNTIME INSTALL"
apt-get -y install vim-runtime >> $LOGFILE
echo "TMUX INSTALL"
apt-get -y install tmux >> $LOGFILE

echo "COPY CONFIG FILES"
cp $DIRPATH/srcs/tmux.conf $USERHOME/.tmux.conf
cp $DIRPATH/srcs/vimrc $USERHOME/.vimrc

echo "INSTALL VIM PLUGINS"
su ${USERNAME} -c "vim +PlugInstall +quitall" >> $LOGFILE

echo "INSTALL YOUCOMPLETEME PLUGIN"
su ${USERNAME} -c "python3 $USERHOME/.vim/plugged/YouCompleteMe/install.py" >> $LOGFILE
