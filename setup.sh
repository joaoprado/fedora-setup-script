#!/usr/bin/env bash

#==================================================================================================
# FILE: setup.sh
# USAGE: ./setup.sh
#==================================================================================================

# WARNING sudo time outs and you need to enter password a few times

source ./variables.sh

#==================================================================================================
# set_hostname
#==================================================================================================
set_hostname() {
    [[ "$(hostname)" == "$NEW_HOSTNAME" ]] && hostnamectl set-hostname "$(hostname)"
}

#==================================================================================================
# set_git_defaults
#==================================================================================================
set_git_defaults() {
    echo "${BOLD}Setting up git globals...${RESET}"

    if [[ -z $(git config --get user.name) ]]; then
        git config --global user.name ${GIT_USER_NAME}
        echo "No global git user name was set, I have set it to ${BOLD}$GIT_USER_NAME${RESET}"
    fi

    if [[ -z $(git config --get user.email) ]]; then
        git config --global user.email ${GIT_EMAIL}
        echo "No global git email was set, I have set it to ${BOLD}$GIT_EMAIL${RESET}"
    fi
}

#==================================================================================================
# system_update
#==================================================================================================
system_update() {
    echo "${BOLD}Running a full system update...${RESET}"
    sudo dnf -y update
}

#==================================================================================================
# add_repositories
#==================================================================================================
add_repositories() {
    echo "${BOLD}Installing RPM fusion and Flatpak repositories...${RESET}"
    sudo rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

#==================================================================================================
# remove_unwanted_software
#==================================================================================================
remove_unwanted_software() {
    while true; do
        read -p "Remove unwanted programs? (Y/n)" yn
        case ${yn} in
            [Yy]* ) sudo dnf -y remove "${TO_REMOVE[@]}"; break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# custom_settings
#==================================================================================================
custom_settings() {
    echo "${BOLD}Changing some custom settings...${RESET}"

    #==============================================================================================
    # setup gnome desktop gsettings
    #==============================================================================================
    echo "${BOLD}Setting up Gnome...${RESET}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0 # Ctrl + Shift + Alt + R to start and stop screencast
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.session idle-delay 1200
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:backspace', 'terminate:ctrl_alt_bksp']"
    gsettings set org.gnome.shell.extensions.auto-move-windows application-list "['org.gnome.Nautilus.desktop:2', 'org.gnome.Terminal.desktop:3', 'code.desktop:1', 'firefox.desktop:1']"
    gsettings set org.gnome.shell enabled-extensions "['pomodoro@arun.codito.in', 'auto-move-windows@gnome-shell-extensions.gcampax.github.com']"
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

    #==============================================================================================
    # make a few little changes
    #==============================================================================================
    [[ ! -d "$HOME/Code" ]] && mkdir "$HOME/Code"

    echo "Xft.lcdfilter: lcdlight" >>"$HOME/.Xresources"
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
    cat >>"$HOME/.bashrc" <<EOL
alias ls="ls -ltha --color --group-directories-first" # l=long listing format, t=sort by modification time (newest first), h=human readable sizes, a=print hidden files
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100" # -C=colorization on, a=print hidden files, t=sort by modification time, r=reversed sort by time (newest first)
EOL
}

#==================================================================================================
# install_dev_software
#==================================================================================================
install_dev_software() {
    install_vim
    install_sublime
    install_gitflow
    install_node
    install_npm_global_packages
    install_php_mysql
    install_composer
    install_docker
    install_powerline
}

#==================================================================================================
# install_vim
#==================================================================================================
install_vim() {
    while true; do
        read -p "Install Vim? (Y/n)" yn
        case ${yn} in
            [Yy]* ) sudo dnf install vim -y; break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_sublime
#==================================================================================================
install_sublime() {
    while true; do
        read -p "Install Sublime? (Y/n)" yn
        case ${yn} in
            [Yy]* ) flatpak install flathub com.sublimetext.three; break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_gitflow
#==================================================================================================
install_gitflow() {
    while true; do
        read -p "Install Git Flow? (Y/n)" yn
        case ${yn} in
            [Yy]* ) sudo dnf install gitflow -y; break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_node
#==================================================================================================
install_node() {
    while true; do
        read -p "Install Node and NPM? (Y/n)" yn
        case ${yn} in
            [Yy]* )
                curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -;
                sudo yum -y install nodejs;
                sudo yum groupinstall 'Development Tools';
                break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_npm_global_packages
#==================================================================================================
install_npm_global_packages() {
    while true; do
        read -p "Install VueJS, Gulp, Webpack and other packages? (Y/n)" yn
        case ${yn} in
            [Yy]* )
                sudo npm install -g eslint babel-eslint eslint-config-standard prettier standard gulp webpack-cli less sass @vue/cli node-sass;
                break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_php_mysql
#==================================================================================================
install_php_mysql() {
    while true; do
        read -p "Install PHP and MySQL CLI? (Y/n)" yn
        case ${yn} in
            [Yy]* )
                sudo dnf -y install php php-common mariadb;
                sudo dnf -y install php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml;
                break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_composer
#==================================================================================================
install_composer() {
    while true; do
        read -p "Install Composer? (Y/n)" yn
        case ${yn} in
            [Yy]* )
                php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');";
                php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;";
                php composer-setup.php;
                php -r "unlink('composer-setup.php');";
                sudo mv composer.phar /usr/bin/composer;
                break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_docker
#==================================================================================================
install_docker() {
    while true; do
        read -p "Install Docker? (Y/n)" yn
        case ${yn} in
            [Yy]* )
                sudo dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine;
                sudo dnf -y install dnf-plugins-core;
                sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo;
                sudo dnf install docker-ce docker-compose -y;
                sudo systemctl start docker;
                sudo systemctl enable docker;
                sudo docker run hello-world;
                sudo usermod -aG docker "${DEFAULT_USER}";
                break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_powerline
#==================================================================================================
install_powerline() {
    while true; do
        read -p "Install Powerline? (Y/n)" yn
        case ${yn} in
            [Yy]* ) sudo dnf install powerline powerline-fonts -y; break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_other_software
#==================================================================================================
install_other_software() {
    install_fedy
    install_media_plugins
    install_spotify
    install_slack

    if [[ ! -z "$TO_INSTALL" ]]; then
        echo "${BOLD}Installing custom software...${RESET}"
        sudo dnf -y install "${TO_INSTALL[@]}"
    fi
}

#==================================================================================================
# install_fedy
#==================================================================================================
install_fedy() {
    while true; do
        read -p "Install Fedy? (Y/n)" yn
        case ${yn} in
            [Yy]* )
                sudo dnf install https://dl.folkswithhats.org/fedora/$(rpm -E %fedora)/RPMS/fedy-release.rpm;
                sudo dnf install fedy -y;
                break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_media_plugins
#==================================================================================================
install_media_plugins() {
    while true; do
        read -p "Install Plugins Players? (Y/n)" yn
        case ${yn} in
            [Yy]* ) sudo dnf -y install gstreamer gstreamer-ffmpeg gstreamer-plugins-bad gstreamer-plugins-bad-free  gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-ugly ffmpeg; break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_spotify
#==================================================================================================
install_spotify() {
    while true; do
        read -p "Install Spotify? (Y/n)" yn
        case ${yn} in
            [Yy]* ) flatpak install flathub com.spotify.Client; break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# install_slack
#==================================================================================================
install_slack() {
    while true; do
        read -p "Install Slack? (Y/n)" yn
        case ${yn} in
            [Yy]* ) flatpak install flathub com.slack.Slack; break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# setup_ssh
#==================================================================================================
setup_ssh() {

    while true; do
        read -p "Setup SSH? (Y/n)" yn
        case ${yn} in
            [Yy]* )
                if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
                    echo "${BOLD}Setting up SSH...${RESET}"
                    ssh-keygen
                    ssh-add ~/.ssh/id_rsa
                    echo "Copy the key and paste to your git accounts"
                    cat ~/.ssh/id_rsa.pub
                    read -p "Press enter to continue"
                fi
                break;;
            [Nn]* ) return 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

#==================================================================================================
# clone_defaults
#==================================================================================================
clone_defaults() {
    echo "${BOLD}Cloning default files and repositories...${RESET}"

    if [[ ! -d "$HOME/setup" ]]; then
        cd ~
        git clone ${DEFAULTS_REPOSITORY} defaults
        sudo cp -f ~/setup/hosts /etc/hosts

        cp -f ~/setup/.bashrc ~/.bashrc
        source ~/.bashrc

        cp -R ~/setup/keys ~/keys
        sudo chmod 400 ~/keys
    fi

    if [[ ! -d "$HOME/Code/docker" ]]; then
        cd ~/Code
        git clone ${LARADOCK_REPOSITORY} docker
    fi
}

#==================================================================================================
# main
#==================================================================================================
main() {
    if [[ $(rpm -E %fedora) -lt 29 ]]; then
        echo >&2 "You must install at least ${GREEN}Fedora 29${RESET} to use this script" && exit 1
    fi

    clear
    cat <<EOL

${BOLD}The hostname will be set to:${RESET} ${GREEN}${NEW_HOSTNAME}${RESET}
${BOLD}Git globals will be set to:${RESET} USER_NAME ${GREEN}${GIT_USER_NAME}${RESET} EMAIL ${GREEN}${GIT_EMAIL}${RESET}
${BOLD}Programs to remove:${RESET} ${GREEN}${TO_REMOVE[*]}${RESET}
${BOLD}Programs to install:${RESET} ${GREEN}${TO_INSTALL[*]}${RESET}
EOL

    set_hostname
    set_git_defaults
    system_update
    add_repositories
    remove_unwanted_software
    custom_settings
    install_dev_software
    install_other_software
    setup_ssh
    clone_defaults

    post_install

    cat <<EOL
  ===================================================
  REBOOT NOW!!!! (or things may not work as expected)
  shutdown -r
  ===================================================
EOL
}

main
