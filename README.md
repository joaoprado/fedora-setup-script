# Fedora Ultimate Setup Script

![alt text](https://github.com/David-Else/fedora-ultimate-setup-script/blob/master/script-screenshot.png)

The ultimate post-installation setup script for Fedora 29+ Workstation.

Using the [official Fedora 29 Workstation ISO](https://getfedora.org) create your perfect Fedora experience and save it to a USB drive to preserve forever!

## Online Usage

- Download the repository using git, CD into the directory, and run:

```
git clone https://github.com/David-Else/fedora-ultimate-setup-script
cd fedora-ultimate-setup-script
./fedora-ultimate-setup-script
```

- Customize the packages you want to install or remove in the **set user preferences** section at the start of the script

The `create_package_list()` function contains all the packages you want to install. It is an associative array in the following format:

```
['type of package']='package-name-1 package-name-2'
```

The 'type of package' is only used for ease of reference and printing the results to the console, the exact wording is not important. The 'package-name' must be the exactly the same as the name you type for `dnf install package-name`

## Offline Usage

- To use this script offline requires you have used it before previously online to generate the .rpm files needed
