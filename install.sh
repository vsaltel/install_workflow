#!/bin/bash

## COLORS       ##
case "${TERM}" in
    xterm-color|*-256color) COLOR_ENABLE=yes;;
esac

if [ "${COLOR_ENABLE}" = yes ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        NC=$(tput sgr0) # No Color
        BOLD=$(tput bold)
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        PURPLE=$(tput setaf 5)
    else
        NC='\[\033[0m\]' # No Color
        BOLD='\[\033[1m\]'
        RED='\[\033[0;31m\]'
        GREEN='\[\033[0;32m\]'
        YELLOW='\[\033[1;33m\]'
        PURPLE='\[\033[1;35m\]'
    fi
fi

## FUNCTIONS    ##
usage() {
    echo -e "${BOLD}${RED}Usage :\n\tsudo ${0}\n\tor as root\n\t${0} [USER]${NC}"
}

command_exists() {
    command -v "${@}" >/dev/null 2>&1
}

## PREREQUISITE ##
PREREQUISITE="dirname getent bash"
for PROG in ${PREREQUISITE}; do
    if ! command_exists ${PROG}; then
        echo -e "${BOLD}${RED}Need ${PROG} program${NC}"
        exit 1
    fi
done

## VARS         ##
DIRPATH=$(dirname ${0})
LOGFILE="${DIRPATH}/logs.txt"
SRC_DIR="${DIRPATH}/srcs"
CONFIG_FILES="bashrc bash_aliases bash_logout vimrc tmux.conf"
PACKET_MANAGER="apt-get -y"
PACKAGES="gcc make cmake curl python3 python3-pip git bash vim vim-gui-common vim-runtime tmux gawk"
COPY_MODE=0
COPY_DIR="${DIRPATH}/workflow_copy"
FONT_NAME="hack"
FONT_ZIP="${FONT_NAME}.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip"

## Init
# Parse args
for i in "${@}"; do
    case ${i} in
        -c)
            COPY_MODE=1
            shift
            ;;
        -*|--*)
            echo "Unknown option ${i}"
            exit 1
            ;;
        *)
            DESTUSER="${i}"
            shift
            ;;
    esac
done

# Get username
if [ "${EUID}" -eq 0 ]; then
    if [ -n "${SUDO_USER}" ]; then
        DESTUSER=${SUDO_USER}
    elif [ -z ${DESTUSER} ]; then
        echo -e "${BOLD}${RED}Cannot install on root user${NC}"
        usage
        exit 2
    fi
else
    echo -e "${BOLD}${RED}Please run as root${NC}"
    usage
    exit 2
fi

# Get user home path
if [ -n ${DESTUSER} ]; then
    USERHOME=$(getent passwd ${DESTUSER} | cut -d: -f6)
    if [ -z ${USERHOME} ]; then
        echo -e "${BOLD}${RED}${DESTUSER} not exist on the system${NC}"
        usage
        exit 3
    fi
    FONT_DIR="${USERHOME}/.local/share/fonts"
else
    echo -e "${BOLD}${RED}User not find${NC}"
    usage
    exit 3
fi

# Create log file
touch ${LOGFILE}

# Copy Mode
if [ "${COPY_MODE}" -eq 1 ]; then
    echo -e "${BOLD}${GREEN}COPY MODE START !${NC}"
    if [ ! -e ${USERHOME}/.vim/plugged/ultisnips/UltiSnips/c.snippets ]; then
        echo -e "${BOLD}${RED}NEED INSTALLATION BEFORE COPY MODE${NC}"
        exit 4
    fi
    mkdir -p ${COPY_DIR}
    echo -e "${BOLD}${GREEN}COPY DIRECTORY CREATED ! (${COPYDIR})${NC}" | tee -a ${LOGFILE}
    cp -R ${USERHOME}/.bashrc ${COPY_DIR}
    cp -R ${USERHOME}/.bash_aliases ${COPY_DIR}
    cp -R ${USERHOME}/.bash_logout ${COPY_DIR}
    cp -R ${USERHOME}/.tmux.conf ${COPY_DIR}
    cp -R ${USERHOME}/.tmux ${COPY_DIR}
    cp -R ${USERHOME}/.vimrc ${COPY_DIR}
    cp -R ${USERHOME}/.vim ${COPY_DIR}
    cp -R ${FONT_DIR} ${COPY_DIR}
    chown -R ${DESTUSER}:${DESTUSER} ${COPY_DIR}
    echo -e "${BOLD}${GREEN}COPY SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
    exit 0
fi

## START        ##
echo -e "${BOLD}${GREEN}INSTALLATION START !${NC}" | tee -a ${LOGFILE}
chown ${DESTUSER}:${DESTUSER} ${LOGFILE}
# Update
echo -e "${BOLD}${YELLOW}UPDATE PACKAGES${NC}" | tee -a ${LOGFILE}
${PACKET_MANAGER} update >> ${LOGFILE}
if [ ${?} -ne 0 ]; then
    echo -e "${BOLD}${RED}UPDATE FAILED${NC}" | tee -a ${LOGFILE}
    exit 5
fi

# Install Packages
echo -e "${BOLD}${YELLOW}INSTALL PACKAGES:${NC}" | tee -a ${LOGFILE}
for PACK in ${PACKAGES}; do
    echo -e "${BOLD}${PURPLE}INSTALL ${PACK}${NC}" | tee -a ${LOGFILE}
    ${PACKET_MANAGER} install $PACK >> ${LOGFILE}
    if [ ${?} -ne 0 ]; then
        echo -e "${BOLD}${RED}${PACK} INSTALLATION FAILED${NC}" | tee -a ${LOGFILE}
        exit 5
    fi
done

# Copy srcs files
echo -e "${BOLD}${YELLOW}COPY CONFIG FILES${NC}" | tee -a ${LOGFILE}
for FILE in ${CONFIG_FILES}; do
    cp ${SRC_DIR}/${FILE}           ${USERHOME}/.${FILE}
    chown ${DESTUSER}:${DESTUSER}   ${USERHOME}/.${FILE}
done

# Set user default shell
if command_exists chsh; then
    echo -e "${BOLD}${YELLOW}SET BASH DEFAULT SHELL${NC}" | tee -a ${LOGFILE}
    chsh -s /bin/bash ${DESTUSER}
fi

# Install fonts
echo -e "${BOLD}${YELLOW}INSTALL FONT ${FONT_NAME}${NC}" | tee -a ${LOGFILE}
curl -Ls ${FONT_URL} --output "${DIRPATH}/${FONT_ZIP}"
if [ ${?} -eq 0 ]; then
    unzip -d "${DIRPATH}/${FONT_NAME}" "${DIRPATH}/${FONT_ZIP}" >> ${LOGFILE}
    rm ${DIRPATH}/${FONT_NAME}/*Windows*
    mkdir -p ${FONT_DIR}
    cp -R ${DIRPATH}/${FONT_NAME}/*.ttf ${FONT_DIR}
    chown -R ${DESTUSER}:${DESTUSER} ${FONT_DIR}
    if command_exists fc-cache; then
        fc-cache -f -v >> ${LOGFILE}
    fi
    echo -e "${BOLD}${GREEN}FONT INSTALLED ! (DONT FORGET TO SET IT !)${NC}" | tee -a ${LOGFILE}
fi
rm -Rf "${DIRPATH}/${FONT_NAME}" "${DIRPATH}/${FONT_ZIP}" &>> ${LOGFILE}

## Tmux Setup
# Install tpm
echo -e "${BOLD}${YELLOW}INSTALL TMUX PLUGIN MANAGER${NC}" | tee -a ${LOGFILE}
echo "run '${USERHOME}/.tmux/plugins/tpm/tpm'" >> ${USERHOME}/.tmux.conf
su ${DESTUSER} -c "git clone -q https://github.com/tmux-plugins/tpm ${USERHOME}/.tmux/plugins/tpm" 2>> ${LOGFILE}
if [ -e ${USERHOME}/.tmux/plugins/tpm ]; then
    # Install tmux plugins
    echo -e "${BOLD}${YELLOW}INSTALL TMUX PLUGINS${NC}" | tee -a ${LOGFILE}
    chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.tmux
    su ${DESTUSER} -c "${USERHOME}/.tmux/plugins/tpm/bin/install_plugins" &>> ${LOGFILE}
fi

## Vim Setup
# Install vim-plug
echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGIN MANAGER${NC}" | tee -a ${LOGFILE}
su ${DESTUSER} -c "curl -fLo ${USERHOME}/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" &>> ${LOGFILE}
if [ ${?} -eq 0 ]; then
    # Install vim plugins
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGINS${NC}" | tee -a ${LOGFILE}
    su ${DESTUSER} -c "vim +'PlugInstall --sync' +quitall" &>> ${LOGFILE}
    if [ ${?} -eq 0 ]; then
        # Install youcompleteme vim plugin
        echo -e "${BOLD}${YELLOW}INSTALL YCM SERVER${NC}" | tee -a ${LOGFILE}
        su ${DESTUSER} -c "python3 ${USERHOME}/.vim/plugged/YouCompleteMe/install.py" >> ${LOGFILE}
    fi
    # Copy vim plugins config
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGINS CONFIG${NC}" | tee -a ${LOGFILE}
    mkdir -p ${USERHOME}/.vim/plugged/ultisnips/UltiSnips
    cp ${DIRPATH}/srcs/c.snippets       ${USERHOME}/.vim/plugged/ultisnips/UltiSnips/c.snippets
    chown -R ${DESTUSER}:${DESTUSER}    ${USERHOME}/.vim/plugged/ultisnips/UltiSnips
fi

echo -e "${BOLD}${GREEN}INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
