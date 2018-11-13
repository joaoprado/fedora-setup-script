# Fedora Ultimate Setup Script

Using only the [official Fedora 29 Workstation ISO](https://getfedora.org) create your perfect Fedora experience and save it to a USB drive to preserve forever!

![screenshot](https://github.com/David-Else/fedora-ultimate-setup-script/blob/master/script-screenshot.png)

# How to Use

## Installation

Download this repository using git, CD into the directory, and run:

```
git clone https://github.com/David-Else/fedora-ultimate-setup-script
cd fedora-ultimate-setup-script
./fedora-ultimate-setup-script
```

Now follow the on-screen instructions.

## Offline Mode

To use this script offline requires you have used it before previously online to generate the .rpm files needed

### Customize the packages you want to install or remove

The `create_package_list()` function contains all the packages you want to install. It contains an associative array in the following format:

```
['category of package']='package-name-1 package-name-2'
```

The `'category of package'` string is only used for categorization and printing the results to the console, the exact wording is not important. The `'package-name'` string must be exactly the same as the name you type when using `dnf install package-name`.

To remove packages just edit the `REMOVE_LIST` array.

```
REMOVE_LIST=(gnome-photos gnome-documents rhythmbox totem cheese)
```

### Customize the adding of repositories

In the `add_repositories()` function you will see [RPM Fusion](https://rpmfusion.org/) and [Flathub](https://flathub.org/home) are installed by default. After that certain packages trigger certain repositories to be installed. You can add your own here.

### Customize the setting up of programs

Later in the script in the `main()` function certain packages trigger certain actions. This functionality is contained in a case statement in the following format (note the spaces around the package names):

```
    case " ${PACKAGES_TO_INSTALL[*]} " in
    *' code '*)
        # do something
        ;;&
    *' nodejs '*)
        # do something
        ;;&
    esac
```

This is where you can add custom commands or functions to setup the packages you have chosen to install.
