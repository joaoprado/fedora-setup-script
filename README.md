# Fedora Ultimate Setup Script

The ultimate post-installation setup script for Fedora 29+ Workstation.

![screenshot](https://github.com/David-Else/fedora-ultimate-setup-script/blob/master/script-screenshot.png)

Using the [official Fedora 29 Workstation ISO](https://getfedora.org) create your perfect Fedora experience and save it to a USB drive to preserve forever!

### Customize the packages you want to install or remove

The `create_package_list()` function contains all the packages you want to install. It is an associative array in the following format:

```
['category of package']='package-name-1 package-name-2'
```

The `'category of package'` string is only used for caterogrization and printing the results to the console, the exact wording is not important. The `'package-name'` string must be exactly the same as the name you type when using `dnf install package-name`.

To remove programs just edit the `REMOVE_LIST` array.

```
REMOVE_LIST=(gnome-photos gnome-documents rhythmbox totem cheese)
```

### Customize the setting up of repositories

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

This is where you can add custom commands or add functions to set up the packages you have chosen to install.

## Online Usage

- Download the repository using git, CD into the directory, and run:

```
git clone https://github.com/David-Else/fedora-ultimate-setup-script
cd fedora-ultimate-setup-script
./fedora-ultimate-setup-script
```

## Offline Usage

- To use this script offline requires you have used it before previously online to generate the .rpm files needed
