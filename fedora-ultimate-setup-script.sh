#!/bin/bash

#==================================================================================================
#
#         FILE: fedora-ultimate-setup-script.sh
#        USAGE: fedora-ultimate-setup-script.sh
#
#  DESCRIPTION: Post-installation setup script for Fedora 29 Workstation
#      WEBSITE: https://www.elsewebdevelopment.com/
#
# REQUIREMENTS: Fresh copy of Fedora 29 installed on your computer
#       AUTHOR: David Else
#      COMPANY: Else Web Development
#      VERSION: 2.0
#==================================================================================================

set -euo pipefail
GREEN=$(tput setaf 2)
BOLD=$(tput bold)
RESET=$(tput sgr0)

#==================================================================================================
# check dependencies
#==================================================================================================
function check_dependencies() {
    if [[ $(rpm -E %fedora) -lt 29 ]]; then
        echo >&2 "You must install at least ${GREEN}Fedora 29${RESET} to use this script" && exit 1
    fi
}

#==================================================================================================
# set user preferences
#==================================================================================================
GIT_EMAIL='example@example.com'
GIT_USER_NAME='David'
REMOVE_LIST=(gnome-photos gnome-documents rhythmbox totem cheese)

create_package_list() {
    declare -A packages=(
        ['drivers']='libva-intel-driver fuse-exfat'
        ['multimedia']='mpv ffmpeg mkvtoolnix-gui shotwell'
        ['utils']='gnome-tweaks tldr whipper keepassx transmission-gtk lshw mediainfo klavaro youtube-dl'
        ['gnome_extensions']='gnome-shell-extension-auto-move-windows.noarch gnome-shell-extension-pomodoro'
        ['emulation']='winehq-stable dolphin-emu mame'
        ['audio']='jack-audio-connection-kit'
        ['backup_sync']='borgbackup syncthing'
        ['languages']='java-1.8.0-openjdk nodejs php php-json'
        ['webdev']='code chromium chromium-libs-media-freeworld docker docker-compose zeal ShellCheck'
        ['firefox extensions']='mozilla-https-everywhere mozilla-privacy-badger mozilla-ublock-origin'
    )
    for package in "${!packages[@]}"; do
        echo "$package: ${GREEN}${packages[$package]}${RESET}" >&2
        PACKAGES_TO_INSTALL+=(${packages[$package]})
    done
}

#==================================================================================================
# add repositories
#==================================================================================================
add_repositories() {
    sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    if [[ ${PACKAGES_TO_INSTALL[*]} == *'winehq-stable'* ]]; then
        sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/Emulators:/Wine:/Fedora/Fedora_29_standard/Emulators:Wine:Fedora.repo
    fi

    if [[ ${PACKAGES_TO_INSTALL[*]} == *'code'* ]]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi
}

#==================================================================================================
# setup desktop
#==================================================================================================
setup_desktop() {
    mkdir "$HOME/sites"
    echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
    touch ~/Templates/empty-file # so you can create new documents from nautilus
    cat >>"$HOME/.bashrc" <<EOL
alias ls="ls -ltha --color --group-directories-first" # l=long listing format, t=sort by modification time (newest first), h=human readable sizes, a=print hidden files
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100" # -C=colorization on, a=print hidden files, t=sort by modification time, r=reversed sort by time (newest first)
EOL

    #==============================================================================================
    # setup pulse audio
    #
    # *pacmd list-sinks | grep sample and see bit-depth available for interface
    # *pulseaudio --dump-re-sample-methods and see re-sampling available
    #
    # *MAKE SURE your interface can handle s32le 32bit rather than the default 16bit
    #==============================================================================================
    sudo sed -i "s/; default-sample-format = s16le/default-sample-format = s32le/g" /etc/pulse/daemon.conf
    sudo sed -i "s/; resample-method = speex-float-1/resample-method = speex-float-10/g" /etc/pulse/daemon.conf
    sudo sed -i "s/; avoid-resampling = false/avoid-resampling = true/g" /etc/pulse/daemon.conf

    #==============================================================================================
    # setup gnome desktop gsettings
    #==============================================================================================
    gsettings set org.gnome.settings-daemon.plugins.media-keys max-screencast-length 0 # Ctrl + Shift + Alt + R to start and stop screencast
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.session idle-delay 1200
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:backspace', 'terminate:ctrl_alt_bksp']"
    gsettings set org.gnome.shell.extensions.auto-move-windows application-list "['org.gnome.Nautilus.desktop:2', 'org.gnome.Terminal.desktop:3', 'code.desktop:1', 'firefox.desktop:1']"
    gsettings set org.gnome.shell enabled-extensions "['pomodoro@arun.codito.in', 'auto-move-windows@gnome-shell-extensions.gcampax.github.com']"
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

}

#==================================================================================================
# setup visual studio code
#==================================================================================================
setup_vscode() {
    local code_extensions=(ban.spellright bierner.comment-tagged-templates
        dbaeumer.vscode-eslint deerawan.vscode-dash esbenp.prettier-vscode
        foxundermoon.shell-format mkaufman.HTMLHint msjsdiag.debugger-for-chrome
        ritwickdey.LiveServer timonwong.shellcheck WallabyJs.quokka-vscode
        Zignd.html-css-class-completion)
    echo
    for extension in "${code_extensions[@]}"; do
        code --install-extension "$extension"
    done

    cat >"$HOME/.config/Code/User/settings.json" <<EOL
// Place your settings in this file to overwrite the default settings
{
  // VS Code 1.28.0 general settings
  "editor.renderWhitespace": "all",
  "editor.dragAndDrop": false,
  "editor.formatOnSave": true,
  "editor.minimap.enabled": false,
  "editor.detectIndentation": false,
  "editor.showUnused": false,
  "workbench.activityBar.visible": false,
  "window.menuBarVisibility": "toggle",
  "window.titleBarStyle": "custom",
  "zenMode.fullScreen": false,
  "zenMode.centerLayout": false,
  "zenMode.restore": true,
  "telemetry.enableTelemetry": false,
  "git.autofetch": true,
  "git.enableSmartCommit": true,
  "git.decorations.enabled": false,
  "php.validate.executablePath": "/usr/bin/php",
  "extensions.showRecommendationsOnlyOnDemand": true,
  "[javascript]": {
    "editor.tabSize": 2
  },
  "[json]": {
    "editor.tabSize": 2
  },
  "[css]": {
    "editor.tabSize": 2
  },
  "[html]": {
    "editor.tabSize": 2
  },
  // Shell Format extension
  "shellformat.flag": "-i 4",
  // Live Server extension
  "liveServer.settings.donotShowInfoMsg": true,
  "liveServer.settings.ChromeDebuggingAttachment": true,
  "liveServer.settings.AdvanceCustomBrowserCmdLine": "/usr/bin/chromium-browser --remote-debugging-port=9222",
  // Spell Right extension
  "spellright.language": "English (British)",
  // Prettier formatting extension
  "prettier.singleQuote": true,
  "prettier.trailingComma": "all",
  // HTML formatting
  "html.format.endWithNewline": true,
  "html.format.wrapLineLength": 80,
  "workbench.statusBar.feedback.visible": false,
  "spellright.documentTypes": ["markdown", "latex", "plaintext"],
  // Various
  "css.lint.zeroUnits": "warning",
  "css.lint.important": "warning",
  "css.lint.universalSelector": "warning",
  "npm.enableScriptExplorer": true,
  "explorer.decorations.colors": false,
  "javascript.updateImportsOnFileMove.enabled": "always",
  "javascript.preferences.quoteStyle": "single",
  "html-css-class-completion.enableEmmetSupport": true,
  "eslint.run": "onSave",
  "json.format.enable": false,
  "editor.lineNumbers": "off",
  "search.followSymlinks": false
}
EOL
}

#==================================================================================================
# setup jack
#==================================================================================================
setup_jack() {
    echo
    sudo usermod -a -G jackuser "$USERNAME" # Add current user to jackuser group
    sudo tee /etc/security/limits.d/95-jack.conf <<EOL
# Default limits for users of jack-audio-connection-kit

@jackuser - rtprio 98
@jackuser - memlock unlimited

@pulse-rt - rtprio 20
@pulse-rt - nice -20
EOL
}

#==================================================================================================
# setup shfmt
#
# *used for vs code shell format extension
# *binary must be in current directory https://github.com/mvdan/sh/releases
#==================================================================================================
function setup_shfmt() {
    if [[ -f ./shfmt_v2.5.1_linux_amd64 ]]; then
        chmod +x shfmt_v2.5.1_linux_amd64
        sudo mv shfmt_v2.5.1_linux_amd64 /usr/local/bin/shfmt
    else
        echo "Could not find ${BOLD}shfmt_v2.5.1_linux_amd64${RESET} file, skipping install"
    fi
}

#==================================================================================================
# setup git
#==================================================================================================
setup_git() {
    if [[ -z $(git config --get user.name) ]]; then
        git config --global user.name $GIT_USER_NAME
        echo "No global git user name was set, I have set it to ${BOLD}$GIT_USER_NAME${RESET}"
    fi

    if [[ -z $(git config --get user.email) ]]; then
        git config --global user.email $GIT_EMAIL
        echo "No global git email was set, I have set it to ${BOLD}$GIT_EMAIL${RESET}"
    fi
}

#==================================================================================================
# setup subpixel hinting for freetype-freeworld
#==================================================================================================
# setup_freetype_freeworld() {
#     gsettings set org.gnome.settings-daemon.plugins.xsettings hinting slight
#     gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing rgba
#     echo "Xft.lcdfilter: lcddefault" >>"$HOME/.Xresources"
# }

#==================================================================================================
# create offline install
#==================================================================================================
create_offline_install() {
    shopt -s globstar
    cd /var/cache/dnf/

    dnf clean packages
    sudo dnf -y upgrade --downloadonly
    mkdir "$HOME/offline-install-updates"
    sudo mv **/*.rpm "$HOME/offline-install-updates"

    dnf clean packages
    sudo dnf -y install "${PACKAGES_TO_INSTALL[@]}" --downloadonly
    mkdir "$HOME/offline-install-packages"
    sudo mv **/*.rpm "$HOME/offline-install-packages"
    echo
    echo "Your .rpm files live in ${GREEN}~/offline-install-updates${RESET} and ${GREEN}~/offline-install-packages${RESET}"
    echo "Install updates first then packages with ${GREEN}sudo dnf install *.rpm${RESET} in respective directories"
}

#==================================================================================================
# main
#==================================================================================================
main() {
    local hostname
    clear
    check_dependencies
    echo "${BOLD}Programs to add:${RESET}"
    echo
    create_package_list
    echo
    echo "${BOLD}Programs to remove:${RESET}"
    echo
    echo "${GREEN}${REMOVE_LIST[*]}${RESET}"
    echo
    read -p "Proceed with these options? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Adding repositories..."
        add_repositories
        echo
        read -p "For offline installation would you like to create a directory of .rpm files with new system updates + new programs and quit? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_offline_install
            exit
        else
            echo
            read -rp "What is this computer's name (hostname)? " hostname
            hostnamectl set-hostname "$hostname"
            echo "Updating Fedora and installing packages..."
            sudo dnf -y remove "${REMOVE_LIST[@]}"
            sudo dnf -y --refresh upgrade
            sudo dnf -y install "${PACKAGES_TO_INSTALL[@]}"
            setup_desktop
            setup_git

            if [[ ${PACKAGES_TO_INSTALL[*]} == *'code'* ]]; then
                setup_vscode
                setup_shfmt
            fi

            if [[ ${PACKAGES_TO_INSTALL[*]} == *'mpv'* ]]; then
                mkdir "$HOME/.config/mpv"
                cat >"$HOME/.config/mpv/mpv.conf" <<EOL
profile=gpu-hq
hwdec=auto
fullscreen=yes
EOL
            fi

            if [[ ${PACKAGES_TO_INSTALL[*]} == *'jack-audio'* ]]; then
                setup_jack
            fi

            cat <<EOL
After installation you may perform these additional tasks:

- mpv addition settings include:
 # gpu-context=drm

 # video-sync=display-resample
 # interpolation
 # tscale=oversample
- Install 'Hide Top Bar' extension from Gnome software
- Firefox "about:support" what is compositor? If 'basic' open "about:config"
  find "layers.acceleration.force-enabled" and switch to true, this will
  force OpenGL acceleration
- Update .bash_profile with
  'PATH=$PATH:$HOME/.local/bin:$HOME/bin:$HOME/Documents/scripts:$HOME/Documents/scripts/borg-backup'
- Consider "sudo dnf install kernel-tools", "sudo cpupower frequency-set --governor performance"
- Files > preferences > views > sort folders before files
- Change shotwell import directory format to %Y/%m + rename lower case, import photos from external drive
- UMS > un-tick general config > enable external network + check force network on interface correct network (wlp2s0)
- Allow virtual machines that use fusefs to intall properly with SELinux # sudo setsebool -P virt_use_fusefs 1
- make symbolic links to media ln -s /run/media/david/WD-Red-2TB/Media/Audio ~/Music
  =================
  REBOOTING NOW!!!!
  shutdown -r
  =================
EOL
        fi
    else
        exit
    fi
}

main
