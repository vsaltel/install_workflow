#!/bin/bash

## COLORS       ##
case "${TERM}" in
    xterm-color|*-256color) COLOR_ENABLE=yes;;
esac

if [ "${COLOR_ENABLE}" = yes ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        NC=$(tput sgr0)
        BOLD=$(tput bold)
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        BLUE=$(tput setaf 4)
        PURPLE=$(tput setaf 5)
        CYAN=$(tput setaf 6)
    else
        NC='\[\033[0m\]'
        BOLD='\[\033[1m\]'
        RED='\[\033[0;31m\]'
        GREEN='\[\033[0;32m\]'
        YELLOW='\[\033[1;33m\]'
        BLUE='\[\033[1;34m\]'
        PURPLE='\[\033[1;35m\]'
        CYAN='\[\033[1;36m\]'
    fi
fi

## FUNCTIONS    ##
usage() {
    echo -e "${BOLD}${RED}Usage :\n\tsudo ${0}\n\tor as root\n\t${0} [USER]${NC}"
}

command_exists() {
    command -v "${@}" >/dev/null 2>&1
}

update_packages() {
${PACKET_MANAGER} update >> ${LOGFILE}
if [ ${?} -ne 0 ]; then
    echo -e "${BOLD}${RED}UPDATE FAILED${NC}" | tee -a ${LOGFILE}
    exit 5
fi
}

install_packages() {
    for PCK in ${1}; do
        RET=$(dpkg-query -W --showformat='${Status}\n' ${PCK} 2>> ${LOGFILE} | grep "install ok installed")
        if [ "${RET}" = "" ]; then
            echo -e "${BOLD}${PURPLE}INSTALL PACKAGE ${PCK}${NC}" | tee -a ${LOGFILE}
            ${PACKET_MANAGER} install ${PCK} &>> ${LOGFILE}
            if [ ${?} -ne 0 ]; then
                echo -e "${BOLD}${RED}${PCK} INSTALLATION FAILED${NC}" | tee -a ${LOGFILE}
                exit 5
            fi
        fi
    done
}

uninstall_packages() {
    for PACK in ${1}; do
        RET=$(dpkg-query -W --showformat='${Status}\n' ${PCK} 2>> ${LOGFILE} | grep "install ok installed")
        if [ "${RET}" != "" ]; then
            echo -e "${BOLD}${PURPLE}UNINSTALL PACKAGE ${PACK}${NC}" | tee -a ${LOGFILE}
            ${PACKET_MANAGER} remove $PACK &>> ${LOGFILE}
            if [ ${?} -ne 0 ]; then
                echo -e "${BOLD}${RED}${PACK} UNINSTALLATION FAILED${NC}" | tee -a ${LOGFILE}
                exit 5
            fi
        fi
    done
}

ask_install() {
    echo -ne "${BOLD}${BLUE}Install ${1} ? Y/n${NC}" | tee -a ${LOGFILE}
    read -n1 INPUT
    echo
    if [ ${INPUT} = "y" ] || [ ${INPUT} = "Y" ]; then
        return 0
    fi
    return 1
}

ask_overwrite_conf() {
    if [ -e ${2} ] || [ -e ${3} ]; then
        echo -ne "${BOLD}${BLUE}${1} config exist. Overwrite it ? Y/n${NC}" | tee -a ${LOGFILE}
        read -n1 INPUT
        echo
        if [ ${INPUT} = "y" ] || [ ${INPUT} = "Y" ]; then
            return 0
        else
            return 1
        fi
    fi
    return 0
}

ask_overwrite_bin() {
    INSTALL_BIN=0
    if command_exists ${1}; then
        BIN_VERSION=$(${1} --version | head -1 | sed -e 's|^[^0-9]*||' -e 's| .*||')
        echo -ne "${BOLD}${BLUE}Actual ${1} version is ${BIN_VERSION} . Install lastest ? Y/n${NC}" | tee -a ${LOGFILE}
        read -n1 INPUT
        echo
        if [ ${INPUT} = "y" ] || [ ${INPUT} = "Y" ]; then
            return 0
        else
            return 1
        fi
    fi
    return 0
}

## PREREQUISITE ##
PREREQUISITE="dpkg-query apt-get bash dirname realpath getent tar head grep sed"
for PROG in ${PREREQUISITE}; do
    if ! command_exists ${PROG}; then
        echo -e "${BOLD}${RED}Need ${PROG} program${NC}"
        exit 1
    fi
done

## VARS         ##
DIRPATH=$(realpath $(dirname ${0}))
LOGFILE="${DIRPATH}/logs.txt"
SRC_DIR="${DIRPATH}/srcs"
CONFIG_FILES="zshrc zsh_aliases vimrc tmux.conf tmux.terminfo"
CONFIG_DIRS="zsh vim tmux"
PACKET_MANAGER="apt-get -y"
ZSH_REQUIRED_PACKAGES="zsh curl git gawk silversearcher-ag"
FONT_REQUIRED_PACKAGES="curl unzip"
TMUX_REQUIRED_PACKAGES="tmux git bash"
NVIM_REQUIRED_PACKAGES="git build-essential clang make cmake curl git python2-dev \
	python3 python3-dev ruby-dev python3-pip libperl-dev gettext lazygit npm"
COPY_MODE=0
COPY_DIR="${DIRPATH}/workflow_copy"
FONT_NAME="hack"
FONT_ZIP="${FONT_NAME}.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip"

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
chown ${DESTUSER}:${DESTUSER} ${LOGFILE}

# Copy Mode
if [ "${COPY_MODE}" -eq 1 ]; then
    echo -e "${BOLD}${GREEN}COPY MODE START !${NC}"
    if [ ! -e ${USERHOME}/.vim/plugged/ultisnips/UltiSnips/c.snippets ]; then
        echo -e "${BOLD}${RED}NEED INSTALLATION BEFORE COPY MODE${NC}"
        exit 4
    fi
    mkdir -p ${COPY_DIR}
    echo -e "${BOLD}${GREEN}COPY DIRECTORY CREATED ! (${COPYDIR})${NC}" | tee -a ${LOGFILE}
    for FILE in ${CONFIG_FILES}; do
        cp -R ${USERHOME}/.${FILE} ${COPY_DIR}/${FILE}
    done
    for DIR in ${CONFIG_DIRS}; do
        cp -R ${USERHOME}/.${DIR} ${COPY_DIR}/${DIR}
    done
    cp -R ${FONT_DIR} ${COPY_DIR}/fonts
    chown -R ${DESTUSER}:${DESTUSER} ${COPY_DIR}
    echo -e "${BOLD}${GREEN}COPY SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
    exit 0
fi

echo -e "${BOLD}${GREEN}INSTALLATION START !${NC}" | tee -a ${LOGFILE}

## Update packages
echo -e "${BOLD}${YELLOW}UPDATE PACKAGES${NC}" | tee -a ${LOGFILE}
update_packages

## Install zsh conf
if ask_install "zsh" ; then
    # Install tmux requiered packages
    install_packages "${ZSH_REQUIRED_PACKAGES}"

    # Install zsh conf
    if ask_overwrite_conf "Zsh" "${USERHOME}/.zsh" "${USERHOME}/.zshrc"; then
        # Remove old zsh conf
        echo -e "${BOLD}${YELLOW}REMOVE OLD ZSH CONF${NC}" | tee -a ${LOGFILE}
        if [ -e ${USERHOME}/.zshrc ]; then rm ${USERHOME}/.zshrc &>> ${LOGFILE}; fi
        if [ -e ${USERHOME}/.zsh ]; then rm -Rf ${USERHOME}/.zsh &>> ${LOGFILE}; fi

        # Copy new zsh conf
        echo -e "${BOLD}${YELLOW}COPY ZSH CONF${NC}" | tee -a ${LOGFILE}
        ln -s ${SRC_DIR}/zshrc ${USERHOME}/.zshrc
        chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.zshrc
        ln -s ${SRC_DIR}/zsh_aliases ${USERHOME}/.zsh_aliases
        chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.zsh_aliases

        # Zsh Plugin
        echo -e "${BOLD}${YELLOW}INSTALL ZSH PLUGINS${NC}" | tee -a ${LOGFILE}
        mkdir -p ${USERHOME}/.zsh/plugins
        git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git ${USERHOME}/.zsh/plugins/zsh-syntax-highlighting 2>> ${LOGFILE}
        if [ -e ${USERHOME}/.zsh/plugins/zsh-syntax-highlighting ]; then
            echo "source ${USERHOME}/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${USERHOME}/.zshrc
        fi
        git clone -q https://github.com/zsh-users/zsh-autosuggestions ${USERHOME}/.zsh/plugins/zsh-autosuggestions 2>> ${LOGFILE}
        if [ -e ${USERHOME}/.zsh/plugins/zsh-autosuggestions ]; then
            echo "source ${USERHOME}/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${USERHOME}/.zshrc
        fi
        chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.zsh

        # Lf install
        echo -e "${BOLD}${YELLOW}INSTALL LF${NC}" | tee -a ${LOGFILE}
        mkdir -p ${USERHOME}/.zsh/plugins/lf
        curl -Ls https://github.com/gokcehan/lf/releases/download/r13/lf-linux-amd64.tar.gz --output ${USERHOME}/.zsh/plugins/lf/lf.tar
        if [ -e ${USERHOME}/.zsh/plugins/lf/lf.tar ]; then
            chown ${DESTUSER}:${DESTUSER} ${USERHOME}/.zsh/plugins/lf/lf.tar
            tar -xvf ${USERHOME}/.zsh/plugins/lf/lf.tar -C /usr/local/bin >> ${LOGFILE}
            chmod 755 /usr/local/bin/lf &>> ${LOGFILE}
        fi
    fi

    # Set zsh default shell
    if command_exists chsh; then
        echo -e "${BOLD}${YELLOW}SET ZSH DEFAULT SHELL${NC}" | tee -a ${LOGFILE}
        chsh -s /bin/zsh ${DESTUSER}
    fi
    echo -e "${BOLD}${GREEN}ZSH INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
fi

## Install fonts
if ask_install "${FONT_NAME} font"; then
    # Install font requiered packages
    install_packages "${FONT_REQUIRED_PACKAGES}"

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
    fi
    rm -Rf "${DIRPATH}/${FONT_NAME}" "${DIRPATH}/${FONT_ZIP}" &>> ${LOGFILE}
    echo -e "${BOLD}${GREEN}FONT INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
    echo -e "${BOLD}${GREEN}(dont forget to set the ${FONT_NAME} font)${NC}" | tee -a ${LOGFILE}
fi

## Tmux Setup
if ask_install "tmux"; then
    # Install tmux requiered packages
    install_packages "${TMUX_REQUIRED_PACKAGES}"

    # Install tmux conf
    if ask_overwrite_conf "Tmux" "${USERHOME}/.tmux" "${USERHOME}/.tmux.conf"; then
    # Remove old tmux conf
        echo -e "${BOLD}${YELLOW}REMOVE OLD TMUX CONF${NC}" | tee -a ${LOGFILE}
        if [ -e ${USERHOME}/.tmux.conf ]; then rm ${USERHOME}/.tmux.conf &>> ${LOGFILE}; fi
        if [ -e ${USERHOME}/.tmux ]; then rm -Rf ${USERHOME}/.tmux &>> ${LOGFILE}; fi

        # Copy new tmux conf
        echo -e "${BOLD}${YELLOW}COPY TMUX CONF${NC}" | tee -a ${LOGFILE}
		mkdir -p ${USERHOME}/.tmux
        ln -s ${SRC_DIR}/tmux.conf ${USERHOME}/.tmux.conf
        ln -s ${SRC_DIR}/tmux.terminfo ${USERHOME}/.tmux/tmux.terminfo
        chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.tmux.conf

        # Install tpm
        echo -e "${BOLD}${YELLOW}INSTALL TMUX PLUGIN MANAGER${NC}" | tee -a ${LOGFILE}
        su ${DESTUSER} -c "git clone -q https://github.com/tmux-plugins/tpm ${USERHOME}/.tmux/plugins/tpm" 2>> ${LOGFILE}
        if [ -e ${USERHOME}/.tmux/plugins/tpm ]; then
            # Install tmux plugins
            echo -e "${BOLD}${YELLOW}INSTALL TMUX PLUGINS${NC}" | tee -a ${LOGFILE}
            echo "run '${USERHOME}/.tmux/plugins/tpm/tpm'" >> ${USERHOME}/.tmux.conf
            chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.tmux
            su ${DESTUSER} -c "${USERHOME}/.tmux/plugins/tpm/bin/install_plugins" &>> ${LOGFILE}
        fi
    fi
    echo -e "${BOLD}${GREEN}TMUX INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
fi

## Nvim binary setup
if ask_install "nvim" && ask_overwrite_bin "nvim"; then
    # Uninstall old vim packages
    echo -e "${BOLD}${YELLOW}UNINSTALL NVIM PACKAGES:${NC}" | tee -a ${LOGFILE}
    VIM_UNINSTALL_PACKAGES="gvim neovim vim vim-gui-common vim-runtime gvim vim-tiny vim-common    \
        vim-gui-common vim-nox"
    uninstall_packages "${VIM_UNINSTALL_PACKAGES}"

    # Install nvim packages
    install_packages "${NVIM_REQUIRED_PACKAGES}"

    # Install nvim
    echo -e "${BOLD}${YELLOW}INSTALL NVIM${NC}" | tee -a ${LOGFILE}
    git clone -q https://github.com/neovim/neovim ${DIRPATH}/nvim 2>> ${LOGFILE}
    if [ -e ${DIRPATH}/nvim ]; then
        cd ${DIRPATH}/nvim
		make CMAKE_BUILD_TYPE=RelWithDebInfo &>> ${LOGFILE}
        make install &>> ${LOGFILE}
        if [ ! -e /usr/local/bin/nvim ]; then
            echo -e "${BOLD}${RED}${PACK} NVIM INSTALL FAILED${NC}" | tee -a ${LOGFILE}
            exit 6
        fi
        if command_exists update-alternatives; then
            update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 1 &>> ${LOGFILE}
            update-alternatives --set editor /usr/local/bin/nvim &>> ${LOGFILE}
            update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 1 &>> ${LOGFILE}
            update-alternatives --set vi /usr/local/bin/nvim &>> ${LOGFILE}
        fi
        cd - >> ${LOGFILE}
        rm -Rf ${DIRPATH}/nvim
    fi
    NVIM_INSTALLED="yes"
    echo -e "${BOLD}${GREEN}NVIM INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
fi

## Nvim config setup
if command_exists "nvim" && ask_install "nvim config" && ask_overwrite_conf "NVim" "${USERHOME}/.config/nvim"; then
    if [ ${NVIM_INSTALLED} != "yes" ]; then
        # Install nvim packages
        install_packages "${NVIM_REQUIRED_PACKAGES}"
        echo -e "${BOLD}${RED}PROBABLY NEED TO REINSTALL VIM${NC}" | tee -a ${LOGFILE}
    fi
    # Remove old vim conf
    echo -e "${BOLD}${YELLOW}REMOVE OLD VIM CONF${NC}" | tee -a ${LOGFILE}
    if [ -e ${USERHOME}/.config/nvim ]; then unlink ${USERHOME}/.config/nvim && rm -rf ${USERHOME}/.config/nvim &>> ${LOGFILE}; fi

    # Copy new vim conf
    echo -e "${BOLD}${YELLOW}CREATE LINK TO CONFIG${NC}" | tee -a ${LOGFILE}
	ln -s ${SRC_DIR}/nvim ${USERHOME}/.config/nvim
    chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.config/nvim

    echo -e "${BOLD}${GREEN}NVIM CONFIG INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
fi

echo -e "${BOLD}${GREEN}INSTALLATION IS COMPLETE !${NC}" | tee -a ${LOGFILE}
