#!/bin/bash

## COLORS       ##
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    NC=$(tput sgr0) # No Color
    BOLD=$(tput bold)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    PURPLE=$(tput setaf 5)
else
    NC='\033[0m' # No Color
    BOLD=''
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    PURPLE='\033[1;35m'
fi

## FUNCTIONS    ##
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

## VARS         ##
FORCE_EXEC=0
DIRPATH=$(dirname ${0})
LOGFILE="${DIRPATH}/logs.txt"
PACKAGES="gcc make cmake curl python3 python3-pip git bash vim vim-gui-common vim-runtime tmux"

# FONT
FONT_NAME="hack"
FONT_ZIP="${FONT_NAME}.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip"

## START        ##
# Get username
if [ -n "${1}" -a "${1}" == "-f" ]; then
    FORCE_EXEC=1
    DESTUSER=${USER}
elif [ "${EUID}" -eq 0 ]; then
    if [ -n "${SUDO_USER}" ]; then
        DESTUSER=${SUDO_USER}
    elif [ -n "${1}" ]; then
        DESTUSER=${1}
    else
        echo -e "${BOLD}${RED}Usage :\n\tsudo ${0}\n\tor\n\t${0} [USER]${NC}"
        exit
    fi
else
    echo -e "${BOLD}${RED}Please run as root or force with -f${NC}"
    exit
fi

# Get user home path
if [ -n ${DESTUSER} ]; then
    USERHOME=$(getent passwd ${DESTUSER} | cut -d: -f6)
    if [ -z ${USERHOME} ]; then
        echo -e "${BOLD}${RED}${DESTUSER} not exist on the system${NC}"
        exit
    fi
else
    echo -e "${BOLD}${RED}User not find${NC}"
    exit
fi

FONT_DIR="${USERHOME}/.local/share/fonts"

# Create log file
touch ${LOGFILE}

echo -e "${BOLD}${GREEN}INSTALLATION START !${NC}" | tee -a ${LOGFILE}
# Super user Install
if [ "${FORCE_EXEC}" -eq 0 ]; then
    chown ${DESTUSER}:${DESTUSER} ${LOGFILE}
    # Update
    echo -e "${BOLD}${YELLOW}APT UPDATE${NC}" | tee -a ${LOGFILE}
    apt-get -y update >> ${LOGFILE}
    if [ ${?} -ne 0 ]; then
        echo -e "${BOLD}${RED}UPDATE FAILED${NC}" | tee -a ${LOGFILE}
        exit
    fi

    # Install Packages
    echo -e "${BOLD}${YELLOW}APT INSTALL PACKAGES:${NC}" | tee -a ${LOGFILE}
    for PACK in ${PACKAGES}; do
        echo -e "${BOLD}${PURPLE}INSTALL ${PACK}${NC}" | tee -a ${LOGFILE}
        apt-get -y install $PACK >> ${LOGFILE}
        if [ ${?} -ne 0 ]; then
            echo -e "${BOLD}${RED}${PACK} INSTALLATION FAILED${NC}" | tee -a ${LOGFILE}
            exit
        fi
    done

    # Copy srcs files
    echo -e "${BOLD}${YELLOW}COPY CONFIG FILES${NC}" | tee -a ${LOGFILE}
    cp ${DIRPATH}/srcs/bashrc       ${USERHOME}/.bashrc
    cp ${DIRPATH}/srcs/bash_aliases ${USERHOME}/.bash_aliases
    cp ${DIRPATH}/srcs/bash_logout  ${USERHOME}/.bash_logout
    cp ${DIRPATH}/srcs/vimrc        ${USERHOME}/.vimrc
    cp ${DIRPATH}/srcs/tmux.conf    ${USERHOME}/.tmux.conf
    chown ${DESTUSER}:${DESTUSER}   ${USERHOME}/.bashrc
    chown ${DESTUSER}:${DESTUSER}   ${USERHOME}/.bash_aliases
    chown ${DESTUSER}:${DESTUSER}   ${USERHOME}/.bash_logout
    chown ${DESTUSER}:${DESTUSER}   ${USERHOME}/.vimrc
    chown ${DESTUSER}:${DESTUSER}   ${USERHOME}/.tmux.conf

    # Set user default shell
    if command_exists chsh; then
        echo -e "${BOLD}${YELLOW}SET BASH DEFAULT SHELL${NC}" | tee -a ${LOGFILE}
        chsh -s /bin/bash ${DESTUSER}
    fi

    # Install fonts
    echo -e "${BOLD}${YELLOW}INSTALL FONT ${FONT_NAME}${NC}" | tee -a ${LOGFILE}
    curl -Ls ${FONT_URL} --output ${FONT_ZIP}
    if [ $? -eq 0 ]; then
        unzip -d ${FONT_NAME} ${FONT_ZIP} >> ${LOGFILE}
        rm ${FONT_NAME}/*Windows*
        mkdir -p ${FONT_DIR}
        cp -R ${FONT_NAME}/*.ttf ${FONT_DIR}
        fc-cache -f -v >> ${LOGFILE}
        echo -e "${BOLD}${GREEN}FONT INSTALLED\n! DONT FORGET TO SET IT !${NC}" | tee -a ${LOGFILE}
    fi
    rm -Rf ${FONT_NAME} ${FONT_ZIP} >> ${LOGFILE}

    # Install vim-plug
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGIN MANAGER${NC}" | tee -a ${LOGFILE}
    su ${DESTUSER} -c "curl -fLo ${USERHOME}/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" &>> ${LOGFILE}

    # Install vim plugins
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGINS${NC}" | tee -a ${LOGFILE}
    su ${DESTUSER} -c "vim +'PlugInstall --sync' +quitall" &>> ${LOGFILE}

    # Install youcompleteme vim plugin
    echo -e "${BOLD}${YELLOW}INSTALL YCM SERVER${NC}" | tee -a ${LOGFILE}
    su ${DESTUSER} -c "python3 ${USERHOME}/.vim/plugged/YouCompleteMe/install.py" >> ${LOGFILE}

    # Copy vim plugins config
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGINS CONFIG${NC}" | tee -a ${LOGFILE}
    mkdir -p ${USERHOME}/.vim/plugged/ultisnips/UltiSnips
    cp ${DIRPATH}/srcs/c.snippets       ${USERHOME}/.vim/plugged/ultisnips/UltiSnips/c.snippets
    chown -R ${DESTUSER}:${DESTUSER}    ${USERHOME}/.vim/plugged/ultisnips/UltiSnips

# Normal user Install
elif [ "${FORCE_EXEC}" -eq 1 ]; then
    # Check required packages
    for PACK in ${PACKAGES}; do
        ret=$(dpkg-query -W --showformat='${db:Status-Status}\n' "${PACK}")
        if [ ! "${ret}" == "installed" ]; then
            echo -e "${BOLD}${RED}${PACK} is missing${NC}"
            exit
        fi
    done

    # Copy srcs files
    echo -e "${BOLD}${YELLOW}COPY CONFIG FILES${NC}" | tee -a ${LOGFILE}
    cp ${DIRPATH}/srcs/bashrc       ${USERHOME}/.bashrc
    cp ${DIRPATH}/srcs/bash_aliases ${USERHOME}/.bash_aliases
    cp ${DIRPATH}/srcs/bash_logout  ${USERHOME}/.bash_logout
    cp ${DIRPATH}/srcs/vimrc        ${USERHOME}/.vimrc
    cp ${DIRPATH}/srcs/tmux.conf    ${USERHOME}/.tmux.conf

    # Install fonts
    echo -e "${BOLD}${YELLOW}INSTALL FONT ${FONT_NAME}${NC}" | tee -a ${LOGFILE}
    curl -Ls ${FONT_URL} --output ${FONT_ZIP}
    if [ $? -eq 0 ]; then
        unzip -d ${FONT_NAME} ${FONT_ZIP} >> ${LOGFILE}
        rm ${FONT_NAME}/*Windows*
        mkdir -p ${FONT_DIR}
        cp -R ${FONT_NAME}/*.ttf ${FONT_DIR}
        fc-cache -f -v >> ${LOGFILE}
        echo -e "${BOLD}${GREEN}FONT INSTALLED\n! DONT FORGET TO SET IT !${NC}" | tee -a ${LOGFILE}
    fi
    rm -Rf ${FONT_NAME} ${FONT_ZIP} >> ${LOGFILE}

    # Install vim-plug
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGIN MANAGER${NC}" | tee -a ${LOGFILE}
    curl -fLo ${USERHOME}/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &>> ${LOGFILE}

    # Install vim plugins
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGINS${NC}" | tee -a ${LOGFILE}
    vim +'PlugInstall --sync' +quitall &>> ${LOGFILE}

    # Install youcompleteme vim plugin
    echo -e "${BOLD}${YELLOW}INSTALL YCM SERVER${NC}" | tee -a ${LOGFILE}
    python3 ${USERHOME}/.vim/plugged/YouCompleteMe/install.py >> ${LOGFILE}

    # Copy vim plugins config
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGINS CONFIG${NC}" | tee -a ${LOGFILE}
    mkdir -p ${USERHOME}/.vim/plugged/ultisnips/UltiSnips
    cp ${DIRPATH}/srcs/c.snippets       ${USERHOME}/.vim/plugged/ultisnips/UltiSnips/c.snippets
    chown -R ${DESTUSER}:${DESTUSER}    ${USERHOME}/.vim/plugged/ultisnips/UltiSnips
fi

echo -e "${BOLD}${GREEN}INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
