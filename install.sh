#!/bin/bash

## COLORS       ##
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'

## VARS         ## 
DIRPATH=$(dirname ${0})
LOGFILE="${DIRPATH}/logs.txt"
PACKAGES="gcc make cmake curl python3 python3-pip git zsh vim vim-gui-common vim-runtime tmux"

## FUNCTIONS    ##
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

## BEGIN        ##
if [ "$EUID" -eq 0 ]; then
    if [ -n "${SUDO_USER}" ]; then
        DESTUSER=${SUDO_USER}
    elif [ -n "${1}" ]; then
        DESTUSER=${1}
    else
        echo -e "${RED}Usage :\n\tsudo ${0}\n\tor\n\t${0} [USER]${NC}" | tee -a ${LOGFILE}
        exit
    fi

    if [ -n ${DESTUSER} ]; then
        USERHOME=$(getent passwd ${DESTUSER} | cut -d: -f6)
    else
        echo -e "${RED}User not find${NC}" | tee -a ${LOGFILE}
        exit
    fi

    if [ -z ${USERHOME} ]; then
        echo -e "${RED}${DESTUSER} not exist on the system${NC}" | tee -a ${LOGFILE}
        exit
    fi
else
    echo -e "${RED}Please run as root${NC}" | tee -a ${LOGFILE}
    exit
fi

echo -e "${GREEN}INSTALLATION START !${NC}" | tee -a ${LOGFILE}

echo -e "${YELLOW}APT UPDATE${NC}" | tee -a ${LOGFILE}
apt-get -y update >> ${LOGFILE}
if [ ${?} -ne 0 ]; then
    echo -e "${RED}UPDATE FAILED${NC}" | tee -a ${LOGFILE}
    exit
fi

echo -e "${YELLOW}APT INSTALL PACKAGES:${NC}" | tee -a ${LOGFILE}
for PACK in ${PACKAGES}; do
    echo -e "${PURPLE}INSTALL ${PACK}${NC}" | tee -a ${LOGFILE}
    apt-get -y install $PACK >> ${LOGFILE}
    if [ ${?} -ne 0 ]; then
        echo -e "${RED}${PACK} INSTALLATION FAILED${NC}" | tee -a ${LOGFILE}
        exit
    fi
done

echo -e "${YELLOW}COPY CONFIG FILES${NC}" | tee -a ${LOGFILE}
cp -R ${DIRPATH}/srcs/zsh ${USERHOME}/.zsh
chown -R ${DESTUSER}:${DESTUSER} $USERHOME/.zsh
ln -s $USERHOME/.zsh/zshrc $USERHOME/.zshrc
chown ${DESTUSER}:${DESTUSER} $USERHOME/.zshrc
ln -s $USERHOME/.zsh/zshenv $USERHOME/.zshenv
chown ${DESTUSER}:${DESTUSER} $USERHOME/.zshenv
cp ${DIRPATH}/srcs/vimrc ${USERHOME}/.vimrc
chown ${DESTUSER}:${DESTUSER} $USERHOME/.vimrc
cp ${DIRPATH}/srcs/tmux.conf ${USERHOME}/.tmux.conf
chown ${DESTUSER}:${DESTUSER} ${USERHOME}/.tmux.conf

if command_exists chsh; then
    echo -e "${YELLOW}SET ZSH DEFAULT SHELL${NC}" | tee -a ${LOGFILE}
    chsh -s /bin/zsh ${DESTUSER}
fi

echo -e "${YELLOW}INSTALL VIM PLUGIN MANAGER${NC}" | tee -a ${LOGFILE}
su ${DESTUSER} -c "curl -fLo ${USERHOME}/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" &>> ${LOGFILE}

echo -e "${YELLOW}INSTALL VIM PLUGINS${NC}" | tee -a ${LOGFILE}
su ${DESTUSER} -c "vim +'PlugInstall --sync' +quitall" &>> ${LOGFILE}

echo -e "${YELLOW}INSTALL YOUCOMPLETEME PLUGIN${NC}" | tee -a ${LOGFILE}
su ${DESTUSER} -c "python3 ${USERHOME}/.vim/plugged/YouCompleteMe/install.py" >> ${LOGFILE}

echo -e "${GREEN}INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
