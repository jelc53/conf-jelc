# TODO:

- clight
  - webcams: https://github.com/FedeDP/Clight/issues/241
  - ddcutil: https://github.com/rockowitz/ddcutil/issues/244
- xsecurelock on lid close

# Installation

- [Download Live Version](https://repo-us.voidlinux.org/live/current/)
- flash onto USB drive
- reboot, F12, boot from USB, select RAM option, then set following:
  - if it fails to boot, try editing the GRUB command, adding `nomodeset rd.driver.blacklist=nouveau`
  - root password
  - user
  - bootloader -> select harddrive
  - partitions (if you need to)
  - filesystems
    - 1: vfat: /boot/efi (~512M) !!must be VFAT and first partition!!
    - 2: ext4: / (~100G)
    - 3: swap (~RAM)
    - 4: ext4: /home (~200G)
    - 5: xfs: /data !!DON'T CREATE A NEW FILESYSTEM!!
- if not connected to a hard line:
  - `./wifi.sh '<SSID>' '<PW>'`
- `sudo xbps-install -Sy python3 git`
- `cd /data && git clone https://github.com/danjenson/conf.git`
  - might have to copy over from a USB; github disabled password authentication
  - if you copy it, link it to your home directory `ln -s /data/conf/ ~/`
- `./setup.py <base,ghost,m2> --username <username> --hostname <hostname>`
  - press Enter or enter a password periodically
- `set theme [light|dark] --img <path/to/image>`
  - NOTE: things might look weird and tiny until you set the theme
- sign in to:
  - rclone/gdrive
    - `rclone config`
  - messenger
  - whatsapp
  - github (add ssh keys)
  - firefox
    - change Downloads to scratch
    - set default browser
  - gmail
  - amazon
  - spotify
  - zotero
    - see setup below
  - discord
  - slack
    - change Downloads to scratch
  - steam
    - Steam -> Settings -> Steam Play -> Enable Steam Play for all other titles (checkbox)

# Configuration

## Zotero
- install with `setup.py`
- Firefox -> Extensions -> Zotero Connector -> ... -> Preferences -> Advanced -> Config Editor -> firstSaveToServer -> false
- Download [zotfile](https://www.zotfile.com)
- Edit -> Preferences -> Sync
  - Sync attachment files in My Library using Zotero (uncheck)
- Tools -> Add-ons
  - Gear -> Install Add-on from file...
- Tools -> Zotfile Preferences
  - General Settings
    - Source folder for Attaching New Files
      - `/home/danj/Zotero/storage`
    - Location of files
      - `/home/danj/pdfs/papers`
  - Renaming Rules
    - Format for all Item types Except Patents:
      - `{%t} {- %a} {(%y)}`
    - Delimiter between multiple authors: `, ` (with space)
- To fix name: right click -> manage attachments -> Rename and Move

## NVIDIA

- Use [official docs](https://us.download.nvidia.com/XFree86/Linux-x86_64/515.57/README/index.html), the arch linux docs are out of date
- If you're getting (key) stuttering:
  - try updating xconf with `sudo nvidia-xconfig`
  - try running `__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia picom`
- Boot problems:
  - if you are only every running nvidia, you might just use `nvidia-xconfig` to create an xorg conf
  - can also add `nomodeset rd.driver.blacklist=nouveau` to `/etc/default/grub` on the `GRUB_CMDLINE_LINUX_DEFAULT` line, then run `sudo update-grub`

## Remote Server

- path: `export PATH=~/.local/bin:~/.cargo/bin:~/.pyenv/bin:$PATH`
- install:
  - copy binaries to `~/.local/bin`:
    - [tmux](https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz)
      - `tar xvzf *.tar.gz && cd tmux-*`
      - `./configure --prefix=/home/<USER>/.local/`
      - `make && make install`
    - [git](https://github.com/git/git/tags)
      - `tar xvzf *.tar.gz && cd git-*`
      - `make configure && ./configure --prefix=/home/<USER>/.local/ [--with-curl=/home/<USER>/.local/]`
      - `make && make install`
    - [curl](https://github.com/curl/curl/releases)[OPTIONAL]: if libcurl not
      found by git, i.e. `git remote-https` won't work; afterwords re-run git configure/make/install
      with `--with-curl=...` flag
      - `tar xvzf *.tar.gz && cd curl-*`
      - `./configure --prefix=/home/<USER>/.local/ --with-openssl`
      - `make && make install`
    - [git lfs](https://git-lfs.github.com/)
      - download and link `git-lfs-*/git-lfs` to `~/.local/bin`
    - [node](https://nodejs.org/en/download/)
      - can install binary and then link `../bin` to `~/.local/bin`
    - [nvim](https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-download)
  - alacritty terminfo: ` curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info | tic -x -`
  - rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
    - `cargo install nu --features=extra`
  - pyenv: `curl https://pyenv.run | bash`
    - `pyenv install 3.9.9`
    - `pyenv global 3.9.9`
- dots:
  - `ln -sf ~/conf/dots/.git* ~/`
  - `ln -s ~/conf/dots/config/nushell ~/.config/nushell`
  - `~/conf/setup.py nvim`
  - `ln -s ~/conf/dots/.tmux.conf ~/`
  - `mkdir -p ~/.ipython/profile_default && ln -sf ~/conf/dots/.ipython/* ~/.ipython/profile_default/ && pip install -r ~/conf/dots/.ipython/requirements.txt`
- Incorrect colors? comment out `true-color` block in `~/.config/helix/config.toml`

## Printing

- install `cups`, `cups-filters`, `avahi`, and `nss-mdns`
- add user to printer admin group: `sudo usermod -a -G lpadmin danj`
- enable cupsd and avahi-daemon: `sudo ln -s /etc/sv/{cupsd,avahi-daemon} /var/service/`
- navigate to [cups](http://localhost:631/admin) in the browser:
  - add printer, use driverless IPP Everywhere Canon Driver
  - make it the default printer in Printers -> `<printer name>` -> `Set as Server Default` (right drop-down)
- when logging in to the printer proper, the username is ADMIN and the password is the serial number (Canon Pixma iP110)

## Monitors

To set up a new monitor:

- `arandr` and save screen layout to `~/.config/bspwm/<hostname>/<x11_config_name>.sh`
- add appropriate `bspc config -d 1 2 ...` commands to assign workspaces to monitors
- [PRIME](https://wiki.archlinux.org/title/PRIME#PRIME_render_offload)
  - currently this does very little because several applications are always
    running on the GPU

## Trackpad

- [wiki](https://wiki.archlinux.org/title/Touchpad_Synaptics)
- [options](https://man.archlinux.org/man/synaptics.4)

## Snippets

- add to `~/.config/snippets`
  - [package.json format](https://github.com/rafamadriz/friendly-snippets/blob/main/package.json)
  - [snippet format](https://code.visualstudio.com/docs/editor/userdefinedsnippets)

## Anki

- [wiki](https://github.com/lervag/apy/wiki/Vim) on using apy/anki
- currently not working since version stuck at 2.15 see this [issue](https://github.com/void-linux/void-packages/pull/35238)

## Python

- to install a different version of python: `pyenv install 3.9.9`
- rehash shims: `pyenv rehash`
- to use a different version for a project, run `pyenv local 3.9.9` to set the project version; all commands in this directory will use that version, i.e. `pip install -r requirements.txt`
- to setup pyright, in project root, create a file `pyrightconfig.json` with
  the contents: `{"venvPath": "/home/<user>/.pyenv/versions/", "venv": "<name>"}`; the name could be a python version, i.e. 3.9.9, or a virtualenv

#### Virtualenvs

- `pyenv virtualenv <version> <name>`
- in project root:
  - set project to use env: `pyenv local <name>`
  - `vim pyrightconfig.json`: `{"venvPath": "/home/<user>/.pyenv/versions/", "venv": "<name>"}`
- to remove: `rm -rf ~/.pyenv/versions/<name>`

## rclone - Google Drive

- `ln -s ~/.keys/rclone ~/.config/rclone` if it exists, otherwise:
  - create a config with `rclone config`
  - check for auth in google drive or create a [google client ID](https://rclone.org/drive/#making-your-own-client-id)
  - example: `rclone sync /data gdrive:data --interactive --progress --log-file=/tmp/data-rclone-gdrive.log`

## Microphone

- TODO: switch to pipewire
- use `pavucontrol` to set this
- heaphones with mics:
  - `pavucontrol`
  - Configuration
  - Change device to 'Handsfree Head Unit (HFP)' using the mSBC protocol (if
    supported -- higher quality than CVSD)

## VPN

- setup: `nm-connection-editor`
- connect: `nmcli --ask con up <name>`
- disconnect: `nmcli con down <name>`

## Remote Desktop

- [get an rdp file](https://cluster-checkout.stanford.edu/)
- run `remmina`
- click the triple bars in upper right
- import `*.rdp` file
- right click entry, click edit
  - add login user/password
  - change screenshots directory
  - change shared directory

## Forward Stanford Email

- Forward your @stanford emails to your @gmail via
  https://accounts.stanford.edu/ -> "Manage" -> "Email" -> "Forward email"
- In Gmail, add another email address to "Send mail as" in Gmail under
  "Settings" -> "Accounts and Import" -> in the "Send mail as" section -> "Add
  another email address" and use the "Outgoing server settings" listed under
  IMAP [here](https://uit.stanford.edu/service/office365/configure/generic)

## Latex

- `sudo tlmgr install <package>` or `tex install` with custom nu func
- if you get `Input Pygments...` errors, add `\usepackage[outputdir=build]{minted}`

## Samba server

- Install `samba`
- `sudo smbpasswd -a danj`
- `sudo smbpasswd -e danj`
- edit `/etc/samba/smb.conf`, adding something like the following
- enable service `ln -s /etc/sv/smbd /var/service`

```
[lectures]
   comment = Dan's Lectures
   path = /data/lectures
   valid users = danj
   public = yes
   writable = no
   read only = yes
   printable = no
   create mask = 0765
```

- You can also change `workgroup = MOTOKO-WORKGROUP`
- To connec:
  - Nvidia Shield:
    - Settings -> Device Preferences -> Storage
    - Mount network storage -> `\\<ip_address>\lectures`
    - The domain will be `MOTOKO-WORKGROUP`
    - The username and password will be as you set up above
    - Install VLC for android and allow access to media

## Screensaver

- `xscreensaver`
- good ones:
  - Coral
  - Cubic Grid
  - Dymaxion Map
  - Film Leader
  - Flurry
  - GL Matrix
  - Gravity Well
  - Intermonetary
  - Lament
  - Lockward
  - Loop
  - Maze 3D
  - Meta Balls
  - Mobius Gears
  - Nerve Rot
  - Pac-Man
  - Phosphor
  - Pipes
  - Polytopes
  - Pong
  - Providence
  - Pyro
  - Rocks
  - Rorschach
  - Rubik
  - Scooter
  - Sonar
  - Splodesic
  - Squiral
  - Stairs
  - Star Wars
  - Starfish
  - Stoner View
  - Strange
  - Surfaces
  - Top Block
  - Unknown Pleasures
  - Vermiculate
  - Vigilance
  - Whirlwind Warp
  - Wormhole
  - XAnalogTV
  - XMatrix
