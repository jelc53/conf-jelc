**Preparation**: remove dual-boot, download theme images and conf repo to USB

- Removing dual-boot: removing Windows from my lenovo dual-boot machine from both disk and grub menu https://forums.linuxmint.com/viewtopic.php?t=386957. To do this, install gparted (`sudo apt install gparted`) and unmount, delete and resize partitions from OS partition you want to hold onto (e.g. Ubuntu)
- In the early stages of installation, access to github is limited and so best to store `conf` and any theme images on a USB you can mount and access from root terminal straight away

**Installation**: boot from live iso image of void (flash USB) and run `void-installer` wizard

- Download void image: sha256sum.sig, sha256sum.txt and live version of void that matches operating system (base and non-musl) https://repo-default.voidlinux.org/live/current/
- Prepare USB device: plug in USB, find sdX reference with `fdisk -l`, unmount with `umount /dev/sdX`, and write live image with `dd bs=4M if=/path/to/void-live-ARCH-DATE-VARIANT.iso of=/dev/sdX`
- Boot into flash USB: reboot, F12, select boot from USB (might need to reflash USB using software like ventoy or mkusb if this isn’t working), select RAM option, then set the following:
    - root password
    - user username, password
    - boot loader —> hard drive
    - partitions (if you need to)
    - filesystems
        - 1: vfat: `/boot/efi` (~512Mb) !!Must be VFAT and first partition!!
        - 2: swap (~RAM)
        - 3: ext4: `/` (~100Gb)
        - 4: ext4: `/home` (~200Gb)
        - 5: xfs: `/data` !!Don’t create new filesystem unless first time!!
- Network: If not connected to a hard line, try either using installer wizard (select `wpa`) or run `./wifi.sh '<SSID>' '<PW>'` from root terminal. You need this for `bxps` package manager to work for setup and config scripts
- Install python3 and git: `sudo xbps-install -Sy python3 git`
- Copy `conf` repo and theme images into `/data` , either from mounted USB or GitHub `/data && git clone https://github.com/danjenson/conf.git` (may no longer be possible with GitHub’s new PAT authentication scheme).
- Create symbolic link with home directory: `ln -s /data/conf/ ~`
- Run setup script: `./setup.py <base,ghost,m2> --username <username> --hostname <hostname> --timezone <country/city>` !!Don’t run with `sudo`, best to just input password periodically so user has read and write permissions for any created files!!
- Reboot, login to user, set theme (`set theme <light/dark> —img /path/to/img`) and start xorg display server (`startx`, alias `x` should also work)
- Troubleshooting:
    - WIFI network:  ping [Google.com](http://Google.com) or 8.8.8.8 as a test, if not working, try the following:
        - network manager: if correctly setup, you just need to establish a connection from the terminal using `nmtui` and follow the prompts (recommended)
        - wpa supplicant: follow the instructions in the link below
            
            https://www.reddit.com/r/voidlinux/comments/hjcyun/very_simple_guide_on_how_to_using_wpa_supplicant/?utm_source=share&utm_medium=ios_app&utm_name=iossmf
            
    - Intel firmware error on boot: solve by running `xbps-install sof-firmware` and `xbps-install sof-tools`
    - Keyboard collisions: copy `/usr/lib/udev/hwdb.d/60-keyboard.hwdb` to `/etc/udev/hwdb.d/` and then commented out all the lines that contained the word 'zoom' under the lenovo and ibm sections then i ran `udevadm hwdb --update && udevadm control --reload-rules && udevadm trigger`
    - Shell for root vs users: check available shells using `cat /etc/shells` and modify using instructions from link https://www.tecmint.com/change-a-users-default-shell-in-linux/
    - Rofi app launcher: may run into issues integrating with pywal theme. To handle, look into `~/.config/rofi/config.rasi` and replace `@theme "rofi.rasi"` with `@import "/home/jelc/.config/wal/rofi.rasi"`
    - Pywalfox: there are a number of pip installed packages that may not work if `/home/jelc/.local/bin/` is not added to path.
    

**Updating PATH for Linux**: check what is already included with `echo $env.PATH`, then add the following to `~/.bashrc` to update path to include `/home/jelc/.local/bin/` (as an example). If you use shells other than bash, you may need to do something equivalent in `~/.profile` instead.

```bash
# Add directories to path
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}
pathadd "/home/jelc/.local/bin/"
```

**Graphical user interface**: you can think of it as xorg conf as controlling the "hardware" side and bspwm window manager configs as managing how you want the bspwm desktops mapped to the monitors available

- xorg: display server (hardware controller, )
- bspwm: window manager (`~/.config/bspwm`)
- rofi: application launcher for Xorg display servers (`~/.config/rofi`)
- gtk: GIMP Toolkit, complete set of UI elements (e.g. theme, toolbar) (`~/.config/gtk-3.0`)
- eww: fancy toolbar widgets built on top of GTK, written in rust (`~/.config/eww`)
- sxhkd: desktop key bindings (`~/.config/sxhkd`)
- ranger: vim-inspired file manager, launch from terminal (`/.config/ranger`)
- alacritty: lightweight terminal emulator, written in rust
- nushell: shell written in rust, allows for table operations (`~/.config/nushell`)
- wal: generates color scheme from image (`~/.config/wal`)
- dunst: push notifications (`~/.config/dunst`)

**Mounting media**: usb 

- Find sdX reference with `fdisk -l`
- Mount with ‘sudo mount /dev/sdX /media/usb’. Note, might first need to mkdir. Can now access data from device at /media/usb like any other filesystem.
- Unmount with ‘umount /dev/sdX’ and remove device from machine.

**Establishing services**: e.g. dhcpcd, wpa supplcant, dbus, network manager, etc

- Services available (installed) found here: `/etc/sv`
- Services enabled (running) here: `/var/service` this is done by symbolic link (using `sudo ln -s /etc/sv/<service> /var/service`)
    - enable/disable: `sudo sv up/down <service>`
    - remove: `sudo rm /var/service/<service>`
    

**Text Editor**: Want to take notes and write code using Helix + language plugins (marksman, texlab, clangd) 

- Language Server: provides programming language specific features like code completion, syntax highlighting, markings for warnings and errors, and refactoring routines
- Language Server Protocol (LSP):  open source JSON-RPC-based protocol that coordinates between code editors (or IDEs) and language servers. Allows programming language support to be distributed independently of editor or IDE
- Editor Plugins: individual editors need to provide integration support (plugins) to enable different language servers to function properly via LSP

**Virtual Environments**: Conda vs PyEnv … packaging vs system bloat

- xxx

**Package Management**: Besides defaults and gui interfaces, the primary difference between Linux OS distributions is stability, currency and dependency resolution package managers

https://en.wikipedia.org/wiki/List_of_software_package_management_systems

- MacOS (homebrew, 2009): popular in the Ruby on Rails community.
- Void Linux (xbps + runit, 2008): X Binary Package System
- Fedora (RPM / DNF, Flatpak, OSTree): Continuation of the Red Hat Linux Project
- Debian (apt / dpkg, 1994): Debian Package (low level) and Advanced Package Tool (high-level) are both used for Debian and its derivatives Ubuntu, Linux Mint, etc.
- Arch Linux (pacman + systemd, 2002): bleeding edge of linux with rolling release model

**Data storage**: Create a `/data` disk partition to ensure separation with operating system and allow for distribution changes without loss of important data

- What to store? Config data files … language servers? compilers? packages? not sure …
- What not to store? Data used for modeling or projects should really be in `/home/<usr>/projects` directory for active use and cold storage duplicated on google drive and external hard drive.