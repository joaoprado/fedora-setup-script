# Fedora Setup Script

Script created to make my life easier when setting up a fresh install of Fedora.
The script is heavily based on PHP and JavaScript development, if you are going to use this, tweak it for your
needs.

This script is based on David Else's [Fedora Ultimate Setup Script](https://github.com/David-Else/fedora-ultimate-setup-script) and an earlier version of my own script which was much simpler.

# How to Use

## Installation

Download this repository using git and cd into the directory:

```
git clone https://github.com/joaoprado/fedora-setup-script.git
cd fedora-setup-script
```

You must create a `variables.sh` file, with the following content:
```
#!/usr/bin/env bash
GREEN=$(tput setaf 2)
BOLD=$(tput bold)
RESET=$(tput sgr0)

NEW_HOSTNAME=
DEFAULT_USER=

TO_REMOVE=
TO_INSTALL=
GNOME_EXTENSIONS=

GIT_EMAIL=
GIT_USER_NAME=

DEFAULTS_REPOSITORY=
LARADOCK_REPOSITORY=

post_install() {
    echo "Things to do at the end of the script"
}
```

Then run
```
./setup.sh
```

#### Notes
Enable https://flathub.org to install Spotify, Slack, Sublime and other apps
