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
CONFIG_FILES="zshrc zsh_aliases vimrc tmux.conf"
CONFIG_DIRS="zsh vim tmux"
PACKET_MANAGER="apt-get -y"
ZSH_REQUIRED_PACKAGES="zsh curl git gawk silversearcher-ag"
FONT_REQUIRED_PACKAGES="curl unzip"
TMUX_REQUIRED_PACKAGES="tmux git bash"
VIM_REQUIRED_PACKAGES="libclang-3.9-dev zlib1g-dev libncurses5-dev     \
    libgtk2.0-dev libatk1.0-dev libcairo2-dev libx11-dev libxpm-dev         \
    libxt-dev python2-dev python3-dev ruby-dev libncurses-dev liblua5.2-dev \
    libperl-dev xz-utils build-essential lua5.2 clang cmake curl python3    \
    python3-pip exuberant-ctags git"
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
        cp ${SRC_DIR}/zshrc ${USERHOME}/.zshrc
        chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.zshrc
        cp ${SRC_DIR}/zsh_aliases ${USERHOME}/.zsh_aliases
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
        cp ${SRC_DIR}/tmux.conf ${USERHOME}/.tmux.conf
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

## Vim binary setup
if ask_install "vim" && ask_overwrite_bin "vim"; then
    # Uninstall old vim packages
    echo -e "${BOLD}${YELLOW}UNINSTALL VIM PACKAGES:${NC}" | tee -a ${LOGFILE}
    VIM_UNINSTALL_PACKAGES="gvim vim vim-gui-common vim-runtime gvim vim-tiny vim-common    \
        vim-gui-common vim-nox"
    uninstall_packages "${VIM_UNINSTALL_PACKAGES}"

    # Install vim packages
    install_packages "${VIM_REQUIRED_PACKAGES}"

    # Install vim
    echo -e "${BOLD}${YELLOW}INSTALL VIM${NC}" | tee -a ${LOGFILE}
    git clone -q https://github.com/vim/vim.git ${DIRPATH}/vim 2>> ${LOGFILE}
    if [ -e ${DIRPATH}/vim ]; then
        cd ${DIRPATH}/vim
        ./configure --with-features=huge --enable-multibyte --enable-rubyinterp=yes \
            --enable-python3interp=yes --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes --enable-luainterp=yes --enable-gui=gtk2 --enable-cscope \
            --prefix=/usr/local &>> ${LOGFILE} make VIMRUNTIMEDIR=/usr/local/share/vim/vim90 &>> ${LOGFILE}
        make install &>> ${LOGFILE}
        if [ ! -e /usr/local/bin/vim ]; then
            echo -e "${BOLD}${RED}${PACK} VIM INSTALL FAILED${NC}" | tee -a ${LOGFILE}
            exit 6
        fi
        if command_exists update-alternatives; then
            update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1 &>> ${LOGFILE}
            update-alternatives --set editor /usr/local/bin/vim &>> ${LOGFILE}
            update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1 &>> ${LOGFILE}
            update-alternatives --set vi /usr/local/bin/vim &>> ${LOGFILE}
        fi
        cd - >> ${LOGFILE}
        rm -Rf ${DIRPATH}/vim
    fi
    VIM_INSTALLED="yes"
    echo -e "${BOLD}${GREEN}VIM INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
fi

## Vim config setup
if command_exists "vim" && ask_install "vim config" && ask_overwrite_conf "Vim" "${USERHOME}/.vim" "${USERHOME}/.vimrc"; then
    if [ ${VIM_INSTALLED} != "yes" ]; then
        # Install vim packages
        install_packages "${VIM_REQUIRED_PACKAGES}"
        echo -e "${BOLD}${RED}PROBABLY NEED TO RECOMPILE VIM${NC}" | tee -a ${LOGFILE}
    fi
    # Remove old vim conf
    echo -e "${BOLD}${YELLOW}REMOVE OLD VIM CONF${NC}" | tee -a ${LOGFILE}
    if [ -e ${USERHOME}/.vimrc ]; then rm ${USERHOME}/.vimrc &>> ${LOGFILE}; fi
    if [ -e ${USERHOME}/.vim ]; then rm -Rf ${USERHOME}/.vim &>> ${LOGFILE}; fi

    # Copy new vim conf
    echo -e "${BOLD}${YELLOW}COPY VIM CONF${NC}" | tee -a ${LOGFILE}
    cp ${SRC_DIR}/vimrc ${USERHOME}/.vimrc
    chown -R ${DESTUSER}:${DESTUSER} ${USERHOME}/.vimrc

    # Copy vim plugin manager
    echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGIN MANAGER${NC}" | tee -a ${LOGFILE}
    su ${DESTUSER} -c "curl -fLo ${USERHOME}/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" &>> ${LOGFILE}

    # Install vim plugins
    if [ ${?} -eq 0 ]; then
        echo -e "${BOLD}${YELLOW}INSTALL VIM PLUGINS${NC}" | tee -a ${LOGFILE}
        VIM_PLUGIN_DIR="${USERHOME}/.vim/plugged"
        su ${DESTUSER} -c "vim +'PlugInstall --sync' +quitall" &>> ${LOGFILE}
        if [ ${?} -eq 0 ]; then
            # Install youcompleteme vim plugin
            if [ -e ${VIM_PLUGIN_DIR}/YouCompleteMe ]; then
                su ${DESTUSER} -c "python3 ${VIM_PLUGIN_DIR}/YouCompleteMe/install.py --clangd-completer" >> ${LOGFILE}
            fi
            # Install color_coded
            if [ -e ${VIM_PLUGIN_DIR}/color_coded ]; then
                rm -f ${VIM_PLUGIN_DIR}/color_coded/CMakeCache.txt
                mkdir ${VIM_PLUGIN_DIR}/color_coded/build
                chown -R ${DESTUSER}:${DESTUSER} ${VIM_PLUGIN_DIR}/color_coded
                cd ${VIM_PLUGIN_DIR}/color_coded/build
                su ${DESTUSER} -c "cmake .. -DDOWNLOAD_CLANG=0" &>> ${LOGFILE}
                su ${DESTUSER} -c "make && make install" &>> ${LOGFILE}
                su ${DESTUSER} -c "make clean && make clean_clang" &>> ${LOGFILE}
                cd - >> ${LOGFILE}
            fi
        fi
        # Copy vim plugins config
        echo -e "${BOLD}${YELLOW}COPY VIM PLUGINS CONFIG${NC}" | tee -a ${LOGFILE}
        if [ -e ${SRC_DIR}/c.snippets ]; then
            mkdir -p ${VIM_PLUGIN_DIR}/ultisnips/UltiSnips
            cp ${SRC_DIR}/c.snippets ${VIM_PLUGIN_DIR}/ultisnips/UltiSnips/c.snippets
            chown -R ${DESTUSER}:${DESTUSER} ${VIM_PLUGIN_DIR}/ultisnips/UltiSnips
        fi
    fi
    echo -e "${BOLD}${GREEN}VIM CONFIG INSTALLATION SUCCESSFULL !${NC}" | tee -a ${LOGFILE}
fi

echo -e "${BOLD}${GREEN}INSTALLATION IS COMPLETE !${NC}" | tee -a ${LOGFILE}
