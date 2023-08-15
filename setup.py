#!/usr/bin/env python3
"""
Setup commands for a VOID Linux operating system
"""

import argparse
import asyncio
import functools
import os
import platform
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import time

TASKS = []


def task(func):
    "Task decorator"
    TASKS.append(func.__name__)

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        p("\n")
        p(f"{func.__name__}", "begin")
        func(*args, **kwargs)
        p(f"{func.__name__}", "success")

    return wrapper


@task
def ghost(args):
    "Setup an AMD desktop with an NVIDIA RTX 4090 GPU."
    if not args.hostname:
        args.hostname = "ghost"
    base(args)
    amd_firmware(args)
    rtx_nvidia_gpu(args)
    python(args)
    spotify(args)
    zoom(args)
    clean()
    reboot()


@task
def m2(args):
    "Setup up an Intel Lenovo laptop with an Optimus (Turing) NVIDIA GPU."
    if not args.hostname:
        args.hostname = "m2"
    m1(args)
    optimus_nvidia_gpu(args)

@task
def single(args):
    gtk_theme(args)
    
@task
def m1(args):
    "Setup up an Intel Lenovo laptop."
    if not args.hostname:
        args.hostname = "m1"
    base(args)
    elogind(args)
    intel_firmware(args)
    intel_gpu(args)
    intel_backlight(args)
    python(args)
    spotify(args)
    zoom(args)
    clean()
    reboot()


@task
def base(args):
    "Setup a base VOID system"
    repo_mirror(args)
    add_void_repos(args)
    update()
    turn_off_bell(args)
    keyboard(args)
    trackpad(args)
    timezone(args)
    locale(args)
    user(args)
    non_sudo_binaries(args)
    data_dir(args)
    dbus(args)
    network_manager(args)
    hostname(args)
    time_sync(args)
    sound(args)
    bluetooth(args)
    xorg(args)
    fonts(args)
    bspwm(args)
    ssh(args)
    nushell(args)
    helix(args)
    rclone(args)
    gdrive(args)
    utilities(args)
    block_websites(args)


@task
def soal(args):
    x(f"ln -sf {args.dots_dir}/.bashrc_soal ~/.bashrc")
    bin_path = "/scratch/jelc/.local/bin"
    bin_dir = "/scratch/jelc/.local"
    setup_server(args, bin_path, bin_dir)


@task
def sail(args):
    x(f"ln -sf {args.dots_dir}/.bashrc_sail ~/.bashrc")
    bin_path = os.path.expanduser("~/.local/bin")
    bin_dir = os.path.expanduser("~/.local")
    setup_server(args, bin_path, bin_dir)


def setup_server(args, bin_path, bin_dir):
    if not os.path.exists(bin_path):
        x(f"mkdir -p {bin_path}")
    # TODO(danj): libevent missing from SOAL (2023-02-08)
    # TODO(danj): tmux also fails on SAIL (2023-02-25)
    # tmux_from_tgz(bin_dir)
    curl_from_tgz(bin_dir)
    git_from_tgz(bin_dir)
    nvim_from_tgz(bin_dir)
    julia_from_tgz(bin_dir)
    fd_from_tgz(bin_dir)
    # NOTE: might need to link install location in ~/.nvim to ~/.local/bin
    node_from_src()
    btop_from_src(bin_dir)
    nvim(args)
    python(args)
    nushell(args)
    link_dots(
        args.dots_dir,
        [
            ".gitattributes",
            ".gitconfig",
            ".gitignore_global",
            ".tmux.conf",
        ],
    )
    x("bash ~/.bashrc && cargo install fzf bat ripgrep")


def tmux_from_tgz(bin_dir):
    "Build tmux from source"
    build_from_tgz(
        "https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz",
        bin_dir,
    )


def curl_from_tgz(bin_dir):
    "Build curl from source"
    # https://github.com/curl/curl/releases
    build_from_tgz(
        "https://github.com/curl/curl/releases/download/curl-7_87_0/curl-7.87.0.tar.gz",
        bin_dir,
        "--with-openssl",
    )


def git_from_tgz(bin_dir):
    "Build git from source"
    # https://github.com/git/git/tags
    build_from_tgz(
        "https://github.com/git/git/archive/refs/tags/v2.39.1.tar.gz",
        bin_dir,
        f"--with-curl={bin_dir}",
    )


def nvim_from_tgz(bin_dir):
    "Extract nvim from tgz"
    # https://github.com/neovim/neovim/releases
    path = untar(
        "https://github.com/neovim/neovim/releases/download/v0.8.3/nvim-linux64.tar.gz"
    )
    x(f"mv {path} {bin_dir}/bin/")
    x(f"ln -s {bin_dir}/bin/nvim-linux64/bin/nvim {bin_dir}/bin/nvim")


def julia_from_tgz(bin_dir):
    "setup Julia programming language"
    # https://julialang.org/downloads/
    path = untar(
        "https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.5-linux-x86_64.tar.gz"
    )
    x(f"mv {path} {bin_dir}/bin/")
    x(f"ln -s {bin_dir}/bin/julia-1.8.5/bin/julia {bin_dir}/bin/julia")


def fd_from_tgz(bin_dir):
    # https://github.com/sharkdp/fd/releases
    path = untar(
        "https://github.com/sharkdp/fd/releases/download/v8.6.0/fd-v8.6.0-x86_64-unknown-linux-musl.tar.gz"
    )
    x(f"mv {path} {bin_dir}/bin/")
    x(f"ln -s {bin_dir}/bin/fd-v8.6.0-x86_64-unknown-linux-musl/fd {bin_dir}/bin/fd")


def build_from_tgz(src, bin_dir, flags=None):
    path = untar(src)
    build_from_src(path, bin_dir, flags)


def untar(src):
    dst = "/tmp"
    download(src, dst)
    tgz = os.path.basename(src)
    dirname = re.sub(".tar.gz|.tgz", "", tgz)
    # TODO(danj): fix this trash hack
    if dirname.startswith("v") and "git" in src:
        dirname = dirname.replace("v", "git-")
    elif dirname.startswith("julia"):
        dirname = dirname.replace("-linux-x86_64", "")
    if "zotero" in src:
        x(f"cd {dst} && tar -xf dl")
        dirname = "Zotero_linux-x86_64"
    else:
        x(f"cd {dst} && tar xzf {tgz}")
    return f"{dst}/{dirname}"


def download(src, dst):
    x(f"cd {dst} && curl -L -O '{src}'")


def build_from_src(path, bin_dir, flags=None):
    x(f"cd {path} && make configure", check=False)
    x(f"cd {path} && ./configure --prefix={bin_dir} {flags} && make && make install")


def node_from_src():
    x(
        "wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash"
    )
    x("source ~/.bashrc && nvm install node")


def btop_from_src(bin_dir):
    dst = clone("https://github.com/aristocratos/btop.git")
    x(f"cd {dst} && make && make install PREFIX={bin_dir}")


@task
def elogind(args):
    "setup elogind"
    # switch to elogind
    install("elogind")
    disable("acpid")
    enable("elogind")
    conf = "/etc/elogind/logind.conf"
    replace_line("^#HandleLidSwitch=", "HandleLidSwitch=suspend", conf)
    # replace_line(
    #     "^#HandleLidSwitchExternalPower=", "HandleLidSwitchExternalPower=ignore", conf
    # )
    replace_line("^#HandleLidSwitchDocked=", "HandleLidSwitchDocked=ignore", conf)
    replace_line("^#AllowSuspendInterrupts=no", "AllowSuspendInterrupts=yes", conf)
    # inhibitions
    x(f"sudo cp -r {args.dots_dir}/etc/elogind/system-sleep /etc/elogind/")


@task
def turn_off_bell(_args):
    "turn off bell"
    check_or_add("blacklist pcspkr", "/etc/modprobe.d/nobeep.conf")


@task
def keyboard(args):
    "setup keyboard country"
    if not args.keyboard:
        q("must provide keyboard country")
    check_or_add(f"KEYMAP={args.keyboard}", "/etc/rc.conf")


@task
def trackpad(args):
    "setup trackpad"
    dst = "/etc/X11/xorg.conf.d"
    x(f"sudo mkdir -p {dst}")
    x(f"sudo cp {args.dots_dir}/etc/30-trackpad.conf {dst}")


@task
def timezone(args):
    "setup timezone"
    if not args.timezone:
        q("must provide a timezone")
    x(f"sudo ln -sf /usr/share/zoneinfo/{args.timezone} /etc/localtime")


@task
def locale(args):
    "setup locale"
    if not args.locale:
        q("must provide a locale; list available with `locale -a`")
    replace_line("LANG=", f"LANG={args.locale}", "/etc/locale.conf")


@task
def user(args):
    "create a user with groups"
    if not args.username:
        q("must provide a user name")
    if not args.groups:
        q("must provide groups for user")
    groups = ",".join(args.groups)
    users = x_output("cut -d: -f1 /etc/passwd").split()
    if args.username not in users:
        x(f"sudo useradd {args.username}")
        p(f"*****ENTER {args.username}'s PASSWORD TWICE*****")
        x(f"sudo passwd {args.username}")
    x(f"sudo usermod -aG {groups} {args.username}")
    link_configs(args.dots_dir, "user-dirs.dirs")


@task
def non_sudo_binaries(_args):
    "allow regular user to use binaries without sudo"
    binaries = ", ".join(
        [
            "/usr/bin/shutdown",
            "/usr/bin/reboot",
        ]
    )
    line = f"%wheel ALL=(ALL) NOPASSWD: {binaries}"
    file = "/etc/sudoers"
    x(f'sudo grep -qxF "{line}" {file} || echo "{line}" | sudo EDITOR="tee -a" visudo')


@task
def data_dir(args):
    "setup a /data directory and associated subdirectories and home links"
    x("sudo mkdir -p /data")
    if args.data_disk_uuid and has_disk(args.data_disk_uuid):
        entry = f"UUID={args.data_disk_uuid} /data xfs defaults 0 2"
        check_or_add(entry, "/etc/fstab")
        x("sudo mount -a")
    for path in [
        "/data/repos",
        "/data/imgs",
        "/data/pdfs",
        "/data/.keys",
        "/data/media",
        "/data/scratch",
    ]:
        x(f"mkdir -p {path}")
        x(f"ln -sf {path} ~/")


@task
def repo_mirror(_args):
    "setup VOID repository mirror in US"
    x("sudo mkdir -p /etc/xbps.d", check=False)
    x("sudo cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/", check=False)
    x("sudo sed -i 's|alpha.de.repo|repo-us|g' /etc/xbps.d/*-repository-*.conf")
    update()


@task
def add_void_repos(_args):
    "add void non-free repo"
    install("void-repo-nonfree")
    install("void-repo-multilib")
    install("void-repo-multilib-nonfree")


@task
def dbus(_args):
    "enable dbus service"
    enable("dbus")


@task
def syslog(_args):
    "enable a syslog service"
    install("socklog-void")
    enable(["socklog-unix", "nanoklogd"])


@task
def network_manager(args):
    "setup network manager"
    install(
        [
            "NetworkManager",  # networking bundle
            "NetworkManager-openconnect",  # plugin for VPN
            "network-manager-applet",  # provides nm-connection-editor
            "openconnect",  # for VPNs
        ]
    )
    disable(["dhcpcd", "wpa_supplicant"])
    enable("NetworkManager")
    time.sleep(5)
    if args.ssid and args.pw:
        x(f'sudo nmcli device wifi connect "{args.ssid}" password "{args.pw}"')


@task
def hostname(args):
    "set the hostname"
    if not args.hostname:
        q("must provide hostname")
    x(f"sudo nmcli general hostname {args.hostname}")


@task
def intel_firmware(_args):
    "update intel firmware"
    install("void-repo-nonfree")
    update()
    install("intel-ucode")
    reconfigure_kernel(_args)


@task
def amd_firmware(_args):
    "update AMD firmware"
    install("linux-firmware-amd")


@task
def intel_gpu(_args):
    "setup intell gpu"
    install(
        [
            "intel-video-accel",  # intel gpu drivers
            "mesa-dri",  # OpenGL support
            "mesa-dri-32bit",  # 32bit support (steam)
            "vulkan-loader",  # Vulkan loader
            "mesa-vulkan-intel",  # Vulkan support
        ]
    )


@task
def intel_backlight(_args):
    'allow users in "video" group to modify screen brightness'
    intel_brightness = "/sys/class/backlight/intel_backlight/brightness"
    if exists(intel_brightness):
        x("sudo mkdir -p /etc/udev/rules.d")
        fname = "/etc/udev/rules.d/backlight.rules"
        check_or_add(f'RUN+="/bin/chgrp video {intel_brightness}"', fname)
        check_or_add(f'RUN+="/bin/chmod g+w {intel_brightness}"', fname)


@task
def rtx_nvidia_gpu(args):
    "setup NVIDIA RTX GPU"
    install("void-repo-nonfree")
    update()
    install(["nvidia", "nvtop", "nvidia-libs-32bit"])
    check_or_add(
        "blacklist nouveau",
        "/usr/lib/modprobe.d/nvidia.conf",
    )


@task
def optimus_nvidia_gpu(args):
    "setup (laptop) Optimus NVIDIA GPU"
    install("void-repo-nonfree")
    update()
    install(["nvidia", "nvtop", "nvidia-libs-32bit"])
    # https://us.download.nvidia.com/XFree86/Linux-x86_64/515.57/README/dynamicpowermanagement.html
    x(f"sudo cp {args.dots_dir}/etc/80-nvidia-pm.rules /lib/udev/rules.d/")
    check_or_add(
        "blacklist nouveau",
        "/etc/modprobe.d/nvidia.conf",
    )
    check_or_add(
        'options nvidia "NVreg_DynamicPowerManagement=0x02"',
        "/etc/modprobe.d/nvidia.conf",
    )


@task
def power_management(_args):
    "setup power management"
    # NOTE: avoid on systems with complicated power management, i.e. nvidia
    install("tlp")
    enable("tlp")


@task
def time_sync(_args):
    "setup network time protocol daemon"
    install("chrony")
    enable("chronyd")


@task
def sound(_args):
    "setup sound"
    install(
        [
            "pulseaudio",  # audio server
            "pamixer",  # command line controls, i.e. volume
            "pavucontrol",  # gui for setting input/output devices
            "alsa-plugins-pulseaudio",  # adapter for apps using ALSA
        ]
    )


@task
def bluetooth(args):
    "setup bluetooth"
    install("bluez")
    enable("bluetoothd")
    x(f"sudo usermod -aG bluetooth {args.username}")


@task
def printing(_args):
    "setup services for network printing"
    # NOTE: avahi{-daemon},nss-mdns was taking 11% of power consumption!
    install("cups")
    enable("cupsd")


@task
def xorg(args):
    "setup xorg display server"
    install(
        [
            "arandr",  # graphical xrandr
            "fontmanager",  # preview fonts
            "libX11-devel",  # required by nushell
            "xbanish",  # hide cursor when typing
            "xclip",  # clipboard
            "xdg-utils", # xdg-open, etc
            "xdo",  # x window command issuer
            "xdotool",  # commands for xdo
            "xmodmap",  # setup kemaps in ~/.Xmodmap
            "xorg",  # xorg package
            "xscreensaver",  # screensaver
            "xsecurelock",  # session locking
        ]
    )
    link_dots(
        args.dots_dir,
        [
            ".Xmodmap",
            ".Xresources",
            ".xinitrc",
            ".xscreensaver",
            ".xserverrc",
        ],
    )
    x(f"sudo cp {args.dots_dir}/etc/xorg.conf.docked /etc/X11/")
    # turns of all DPMS management
    # x(f"sudo cp {args.dots_dir}/etc/10-monitor.conf /etc/X11/xorg.conf.d/")


@task
def fonts(args):
    "setup backup fonts"
    _install_nerd_fonts(
        [
            "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.1/FiraCode.zip",
        ]
    )
    install(["noto-fonts-cjk", "noto-fonts-emoji", "fonts-croscore-ttf"])
    link_configs(args.dots_dir, "fontconfig")
    # Install feather for icons
    dst = "~/.local/share/fonts"
    x(f"mkdir -p {dst} && cp -f {args.dots_dir}/fonts/feather.ttf {dst}/")
    # update font cache
    x("sudo fc-cache -fv")


@task
def install_nerd_font(args):
    _install_nerd_fonts([args.font_url])


def _install_nerd_fonts(urls):
    install(["curl", "unzip", "fd"])
    for url in urls:
        x(f"cd /tmp && curl -L {url} -o font.zip && unzip font.zip -d font")
        x("sudo fd . /tmp/font -e ttf -E *Windows* -x mv {} /usr/share/fonts/TTF/{/}")
        x("sudo fc-cache -fv")
        x("rm -rf /tmp/font.zip /tmp/font")


@task
def bspwm(args):
    "setup bspwm window manager and associated gui packages"
    install(
        [
            "Clight",  # brightness
            "Thunar",  # file previewer
            "breeze-cursors",  # breeze cursor theme
            "breeze-icons",  # breeze icon theme
            "bspwm",  # window manager
            "dunst",  # notifications
            "feh",  # wallpaper
            "geoclue2",  # location for Clight
            "lxappearance",  # used for setting theme
            "picom",  # image compositor
            "playerctl",  # used by dunst
            "polkit",  # authenticating services
            "pywal",  # theme creator
            "rofi",  # program selector
            "sxhkd",  # keybindings
            "udiskie",  # auto-mounting drives
            "wmctrl",  # used by rofi
        ]
    )
    enable(["Clightd", "polkitd"])
    link_dots(args.dots_dir, [".xinitrc", ".Xmodmap", ".icons"])
    eww(args)
    gtk_theme(args)
    link_configs(
        args.dots_dir,
        [
            "bspwm",
            "clight.conf",
            "dunst",
            "eww",
            "gtk-3.0",
            "picom",
            "ranger",
            "rofi",
            "sxhkd",
            "wal",
        ],
    )
    # enabling automounting and clight control
    for polkit_file in ["60-udiskie.rules", "70-clightd.rules"]:
        src = os.path.join(args.dots_dir, "etc", polkit_file)
        x(f"sudo cp {src} /etc/polkit-1/rules.d/")


@task
def picom(args):
    "install picom from git repo"
    install(
        [
            "dbus-devel",
            "gcc",
            "libXext-devel",
            "libconfig-devel",
            "libev-devel",
            "libglvnd-devel",
            "meson",
            "ninja",
            "pcre-devel",
            "pixman-devel",
            "pkg-config",
            "uthash",
            "xcb-util-image-devel",
            "xcb-util-renderutil-devel",
        ]
    )
    dst = clone("https://github.com/yshui/picom.git")
    x(f"cd {dst} && git submodule update --init --recursive")
    x(f"cd {dst} && meson --buildtype=plain . build")
    x(f"cd {dst} && ninja -C build")
    x(f"cd {dst}/build && sudo meson install --no-rebuild")
    link_configs(args.dots_dir, "picom")


@task
def eww(args):
    "install eww widgets"
    install(
        [
            "gdk-pixbuf-devel",
            "pango-devel",
            "atk-devel",
            "gtk+3-devel",
            "gtk-layer-shell",
            "gtk-layer-shell-devel",
        ]
    )
    if not shutil.which("rustup"):
        rust(args)
    cargo_home = os.environ.get("CARGO_HOME")
    if not cargo_home:
        cargo_home = os.path.expanduser("~/.cargo")
    cargo = cargo_home + "/bin/cargo"
    dst = clone("https://github.com/elkowar/eww")
    x(
        f"cd {dst} && {cargo} build --release && mkdir -p ~/.local/bin && cp -f target/release/eww ~/.local/bin/"
    )


@task
def gtk_theme(_args):
    """Install custom GTK theme"""
    # update GTK theme
    url = "https://github.com/EliverLara/Sweet/releases/download/v3.0/Sweet-Dark.zip"
    x(f"curl -L {url} -o /tmp/sweet_dark.zip")
    x("cd /usr/share/themes && sudo unzip -o /tmp/sweet_dark.zip ")
    # candy icon set
    url = "https://github.com/EliverLara/candy-icons/archive/refs/heads/master.zip"
    x(f"curl -L {url} -o /tmp/candy_icons.zip")
    x("cd /usr/share/icons && sudo unzip -o /tmp/candy_icons.zip")
    # candy folder icons
    dst = clone("https://github.com/EliverLara/Sweet-folders")
    x(f"cd {dst} && sudo cp -r Sweet-* /usr/share/icons/")


@task
def ssh(_args):
    "setup ssh"
    if not exists("~/.ssh"):
        path = "/data/.keys/ssh"
        if exists(path):
            x(f"ln -s {path} ~/.ssh")
        else:
            x("ssh-keygen")


@task
def nushell(args):
    "install nushell"
    if not shutil.which("rustup"):
        rust(args)
    cargo_home = os.environ.get("CARGO_HOME")
    if not cargo_home:
        cargo_home = os.path.expanduser("~/.cargo")
    cargo = cargo_home + "/bin/cargo"
    if not shutil.which("nu"):
        x(f"{cargo} install nu --features=dataframe")
    link_configs(args.dots_dir, "nushell")
    if is_void():
        set_default_shell_to_nushell(args)


@task
def set_default_shell_to_nushell(args):
    "set default shell as nushell"
    cargo_home = os.environ.get("CARGO_HOME")
    if not cargo_home:
        cargo_home = os.path.expanduser("~/.cargo")
    nu_path = cargo_home + "/bin/nu"
    check_or_add(nu_path, "/etc/shells")
    shell = x_output(f"getent passwd {args.username}").rsplit(":", 1)[-1]
    if nu_path != shell:
        p("*****ENTER PASSWORD TO CHANGE SHELL*****")
        x(f"chsh -s {nu_path} {args.username}")


@task
def helix(args):
    "install helix editor"
    install("helix")
    link_configs(args.dots_dir, ["helix"])
    # NOTE: git-based install
    # dst = clone("https://github.com/helix-editor/helix")
    # x(f"cd {dst} && cargo install --locked --path helix-term")
    # x(f"rm -rf ~/.config/helix/runtime && mv {dst}/runtime ~/.config/helix/")
    # x(f"ln -sf {args.dots_dir}/scripts/tmux-clip-to-repl ~/.local/bin/")


@task
def nvim(args):
    "setup neovim with nvchad"
    # required packages
    install(["git", "wget", "nodejs", "neovim"])
    # clear old configs
    x("rm -rf ~/.config/nvim", check=False)
    x("rm -rf ~/.cache/nvim", check=False)
    x("rm -rf ~/.local/share/nvim", check=False)
    # add nvchad and custom configs, custom `git` because of --depth 1
    x("git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1")
    x(f"ln -sf {args.dots_dir}/config/nvim ~/.config/nvim/lua/custom")
    # link snippets
    link_configs(args.dots_dir, ["snippets"])


@task
def utilities(args):
    "setup basic system utilities"
    install(
        [
            "alacritty",  # terminal
            "bat",  # syntax-higlighting cat
            "btop",  # checking resources
            "fd",  # fast file finder
            "firefox",  # browser
            "flameshot",  # screenshots
            "fuse3",  # fuse mounted directories
            "fzf",  # fuzzy file finder, uses fd
            "ghostscript",  # used for combining pdfs
            "git",  # version control system (vcs)
            "gthumb",  # image previewer
            "ImageMagick",  # provides convert
            "inotify-tools",  # watching files for changes
            "lsof",  # list open files
            "mpv",  # better UI video player
            "powertop",  # monitor power usage
            "ranger",  # terminal file previews
            "ripgrep",  # faster grep
            "tmux",  # terminal simulator
            "tree",  # tree file browser
            "ueberzug",  # terminal image previews
            "unzip",  # for unzipping
            "upower",  # enables nushell power commands
            "vlc",  # media player
            "zathura-pdf-mupdf",  # adds support for ePub, PDF, and XPS
            "zathura",  # pdf viewer
        ]
    )
    link_dots(
        args.dots_dir,
        [
            ".alacritty.yml",
            ".gitattributes",
            ".gitconfig",
            ".gitignore_global",
            ".tmux.conf",
        ],
    )
    link_configs(args.dots_dir, ["gitui"])
    # instantiated wal template will be linked into this directory
    x("mkdir -p ~/.config/zathura")


@task
def block_websites(_args):
    sites = [
        #"www.facebook.com",
        #"facebook.com",
        #"www.instagram.com",
        #"instagram.com",
    ]
    for site in sites:
        check_or_add(f"0.0.0.0			{site}", "/etc/hosts")


@task
def remote_desktop(_args):
    "install remote desktop client"
    install("remmina")


@task
def chrome(_args):
    "install chrome"
    install_restricted("google-chrome")


@task
def discord(_args):
    "install discord"
    install_restricted("discord")


@task
def slack(_args):
    "install slack"
    install_restricted("slack-desktop")


@task
def spotify(_args):
    "install spotify"
    install_restricted("spotify")
    # NOTE: rarely used
    # install(["socklog-void", "spotifyd", "spotify-tui"])
    # enable(["socklog-unix", "nanoklogd"])


@task
def zoom(_args):
    "install zoom"
    install_restricted("zoom")


@task
def dvd(_args):
    "setup dvd watching and ripping software"
    install(
        [
            "libdvdcss",  # decrypting DVDs
            "handbrake",  # ripping DVDs
            "vlc",  # media player
        ]
    )


# CODING LANGUAGE SUPPORT


@task
def javascript(_args):
    "setup node, javascript, and typescript"
    install(["nodejs"])
    x("sudo npm i -g @fsouza/prettierd write-good")


@task
def latex(args):
    "setup latex"
    install(
        [
            "texlive-bin",  # tex and tlmgr
            "biber",  # bibliographies
            "gnupg",  # checks signatures of CTAN pkgs
            "graphviz",  # for dot graphics files
        ]
    )
    pkgs = " ".join(
        [
            "accents",
            "algorithms",
            "algorithmicx",
            "amscls",
            "amsfonts",
            "amsmath",
            "babel",
            "babel-english",
            "bbm",
            "bbm-macros",
            "beamer",
            "biber",
            "biblatex",
            "booktabs",
            "catchfile",
            "epigraph",
            "enumitem",
            "environ",
            "epstopdf-pkg",
            "fancyvrb",
            "fancyhdr",
            "footmisc",
            "framed",
            "fvextra",
            "geometry",
            "graphviz",
            "hyperref",
            "infwarerr",
            "latex",
            "latex-bin",  # installs pdflatex,lualatex,latexmk
            "latexmk",
            "lualatex-math",
            "mathtools",
            "minted",
            "multirow",
            "nextpage",
            "pdfcrop",
            "pgf",
            "physics",
            "silence",
            "tcolorbox",
            "unicode-math",
            "xstring",
        ]
    )
    tlmgr = "/opt/texlive/2023/bin/x86_64-linux/tlmgr"
    x(f"sudo {tlmgr} install {pkgs}")
    link_dots(args.dots_dir, ".latexmkrc")
    # contains math.sty, etc
    link_configs(args.dots_dir, "latex")


@task
def lua(_args):
    "setup lua programming language"
    # base packages
    install(["lua", "lua-devel", "luarocks"])
    # formatting
    x("~/.cargo/bin/cargo install stylua")


@task
def lean(_args):
    "setup lean theorem prover"
    url = "https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh"
    x(f"curl -L {url} -o /tmp/elan-init.sh")
    x("sh /tmp/elan-init.sh --no-modify-path -y")
    x("elan self update")
    x("elan default leanprover/lean4:stable")


@task
def python(args):
    "setup python, ipython, and pyenv"
    install(
        [
            "gobject-introspection",  # matplotlib
            "libffi-devel",  # used by pyenv when building new version
            "python3",  # system python
            "python3-devel",  # python headers for building packages
            "python3-pip",  # system package installer
            "readline-devel",  # used by pyenv
            "sqlite-devel",  # used by pyenv
        ]
    )
    # setup ipython
    x("mkdir -p ~/.ipython/profile_default")
    x(f"ln -sf {args.dots_dir}/.ipython/* ~/.ipython/profile_default")
    # install pyenv
    if not shutil.which("pyenv"):
        x("curl https://pyenv.run | bash")
    # install poetry
    if not shutil.which("poetry"):
        x("curl -sSL https://install.python-poetry.org | python3 -")
    if is_void():
        # install common data science packages
        x(f"pip install -r {args.dots_dir}/.ipython/requirements.txt")
        # install common gui packages
        x(f"pip install -r {args.dots_dir}/.ipython/gui_requirements.txt")


@task
def ruby(args):
    "setup Ruby programming langauge"
    install(["ruby", "ruby-devel"])
    gems = ["bundler", "jekyll"]
    x(f"sudo gem install {' '.join(gems)}")


@task
def r(args):
    "setup R programming language with data science packages"
    install(
        [
            "R",
            "rstudio",
            # required for tidyverse
            "zlib-devel",
            "libcurl-devel",
            "libxml2-devel",
            # required for rstan
            "gcc-fortran",
            "openblas-devel",
            "nodejs-devel",
        ]
    )
    link_dots(args.dots_dir, ".Rprofile")
    x(f"sudo Rscript {args.dots_dir}/scripts/setup.R")


@task
def rust(_args):
    "setup rust programming language"
    install(["pkg-config", "openssl-devel", "gcc"])
    rustup_home = os.environ.get("RUSTUP_HOME")
    if not rustup_home:
        rustup_home = os.path.expanduser("~/.rustup")
    cargo_home = os.environ.get("CARGO_HOME")
    if not cargo_home:
        cargo_home = os.path.expanduser("~/.cargo")
    rustup = cargo_home + "/bin/rustup"
    if shutil.which(rustup):
        x(f"{rustup} update")
    else:
        download_cmd = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs"
        install_cmd = "sh -s -- -y --no-modify-path --default-toolchain nightly"
        x(f"{download_cmd} | {install_cmd}")
    cargo = cargo_home + "/bin/cargo"
    x(f"{cargo} install cargo-edit")
    x(f"{rustup} component add rustfmt --toolchain nightly")


@task
def rclone(_args):
    "install and setup rclone"
    install("rclone")
    rclone_config = "~/.keys/rclone"
    if exists(rclone_config):
        x(f"ln -sf {rclone_config} ~/.config/rclone")


@task
def gdrive(args):
    "setup mount point for google drive"
    x("sudo mkdir -p /gdrive")
    x(f"sudo chown -R {args.username}:{args.username} /gdrive")


@task
def anki(args):
    "install anki and apy for vim editing cards"
    # TODO: update to system package; as of 2022-08-12, void anki is far behind
    # https://github.com/ankitects/anki/blob/main/docs/development.md
    # https://betas.ankiweb.net/
    x("pip install --upgrade --pre aqt[qt6]")
    link_desktops(args.dots_dir, "anki")
    # assisted note takign from CLI
    # x("pip install --user git+https://github.com/lervag/apy.git#egg=apy")
    # link_configs(args.dots_dir, "apy")


# EXPERIMENTAL


@task
def agda(_args):
    "installs agda programming language"
    install(["cabal-install"])
    x("cabal update")
    x("cabal install Agda")
    x("sudo luarocks install luautf8")  # for neovim plugin


@task
def youtube_audio(_args):
    "allow streaming youtube sound from cli"
    install(["mpv", "youtube-dl"])


@task
def hotspot(_args):
    "install linux wifi hotspot"
    install(
        [
            "glib-devel",
            "gtk+3-devel",
            "qrencode-devel",
            "hostapd",
            "dnsmasq",
        ]
    )
    dst = clone("https://github.com/lakinduakash/linux-wifi-hotspot.git")
    x(f"cd {dst} && make && sudo make install")


@task
def neo(_args):
    "install neo command for terminal (matrix screen)"
    install(["ncurses-devel"])
    url = "https://github.com/st3w/neo/releases/download/v0.6.1/neo-0.6.1.tar.gz"
    x(f"curl -L {url} -o /tmp/neo.tgz")
    x("cd /tmp/ && tar xzf neo.tgz")
    x("cd /tmp/neo-* && ./configure && make && sudo make install")


@task
def kiwix(args):
    "install kiwix for hosting wikipedia, etc offline"
    install("kiwix-tools")
    x("mkdir -p /data/kiwix")
    link_configs(args.dots_dir, "Kiwix")
    link_desktops(args.dots_dir, "wiki")


@task
def steam(args):
    """install steam"""
    install(
        [
            "libgcc-32bit",
            "libstdc++-32bit",
            "libdrm-32bit",
            "libglvnd-32bit",
            "steam",
        ]
    )


@task
def zotero(_args):
    "install zotero"
    url = "https://www.zotero.org/download/client/dl?channel=release&platform=linux-x86_64&version=6.0.20"
    path = untar(url)
    x(f"sudo mv {path} /usr/local/bin/")
    x(f"sudo ln -sf /usr/local/bin/Zotero_linux-x86_64/zotero /usr/local/bin/zotero")
    x(
        "sudo cp /usr/local/bin/Zotero_linux-x86_64/zotero.desktop /usr/share/applications/"
    )
    replace_line("^Exec", "Exec=zotero", "/usr/share/applications/zotero.desktop")
    print("see README.md for Zotero setup")


@task
def samba(_args):
    """install samba for NFS"""
    install("samba")
    enable("smbd")


@task
def abcde(args):
    """install abcde cd ripper"""
    install(
        [
            "abcde",
            "cdparanoia",
            "cdrtools",
            "eyeD3",
            "libopusenc",
            "opus-tools",
            "flac",
            "fdkaac",
            "wavpack",
        ]
    )
    dst = "/etc/abcde.conf"
    x(f"sudo rm -f {dst}", check=False)
    x(f"sudo cp {args.dots_dir}/etc/abcde.conf {dst}")


@task
def libtorch(_args):
    "install libtorch"
    # source: https://pytorch.org/get-started/locally/
    url = "https://download.pytorch.org/libtorch/cu117/libtorch-cxx11-abi-shared-with-deps-1.13.0%2Bcu117.zip"
    x(f"curl -L {url} -o /tmp/libtorch.zip")
    x(f"sudo unzip /tmp/libtorch.zip -d /opt/")


@task
def coqgym(_args):
    "Install CoqGym"
    # source: https://github.com/princeton-vl/CoqGym
    install(["lmdb", "opam"])
    ruby(_args)
    x("opam init")
    x("opam switch create 4.07.1+flambda && eval $(opam env)")
    x("opam upgrade && eval $(opam env)")
    src = "https://github.com/princeton-vl/CoqGym"
    dst = "/data/repos/coqgym"
    clone(src, dst)
    x("cd coqgym && source install.sh")
    x("cd coq_projects && make && cd ..")


@task
def apptainer(_args):
    "Install Apptainer"
    # TODO(danj): fuse2fs
    # https://github.com/void-linux/void-packages/issues/42150
    install(
        [
            "autoconf",
            "automake",
            "cryptsetup",
            "efsprogs",
            "efsprogs-devel",
            "fakeroot",
            "fuse",
            "fuse-devel",
            "gcc",
            "go",
            "libseccomp-devel",
            "libtool",
            "libuuid-devel",
            "openssl-devel",
            "squashfs-tools",
            "zlib",
        ]
    )
    src = "https://github.com/vasi/squashfuse.git"
    dst = "/data/repos/squashfuse"
    clone(src, dst)
    x(f"cd {dst} && ./autogen.sh && ./configure && make && sudo make install")

    src = "https://github.com/apptainer/apptainer.git"
    dst = "/data/repos/apptainer"
    clone(src, dst)
    x(f"cd {dst} && ./mconfig && cd ./builddir && make && sudo make install")


@task
def docker(args):
    "install docker and enable daemon"
    install("docker")
    enable("docker")
    x(f"sudo usermod -aG docker {args.username}")


def x(cmd, check=True, echo=True):
    "execute command streaming stdin, stdout, and stderr"
    if echo:
        p(cmd)
    loop = asyncio.new_event_loop()
    return_code = loop.run_until_complete(_x(cmd))
    if check and return_code:
        q(f'"{cmd}" failed!')


async def _x(cmd):
    pipe = await asyncio.create_subprocess_shell(
        cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )
    await asyncio.wait(
        [
            asyncio.create_task(_stream(pipe.stdout)),
            asyncio.create_task(_stream(pipe.stderr)),
        ]
    )
    return await pipe.wait()


async def _stream(stream):
    "stream output"
    while True:
        line = await stream.readline()
        if line:
            p("\t" + line.decode("utf-8").strip())
        else:
            break


def x_output(cmd, echo=True):
    "execute command and collect stdout"
    if echo:
        p(cmd)
    try:
        out = subprocess.check_output(cmd, shell=True)
    except subprocess.CalledProcessError as err:
        q(str(err))
    return out.decode("utf-8").strip()


def enable(svs):
    "enable a service on VOID linux"
    if not isinstance(svs, list):
        svs = [svs]
    for sv in svs:
        x(f"sudo ln -sf /etc/sv/{sv} /var/service/")


def disable(svs):
    "disable a service on VOID linux"
    if not isinstance(svs, list):
        svs = [svs]
    for sv in svs:
        x(f"sudo rm /var/service/{sv}", check=False)


def install(pkgs):
    "install packages on VOID linux, ignores otherwise"
    if is_void():
        if not isinstance(pkgs, list):
            pkgs = [pkgs]
        pkgs = " ".join(pkgs)
        x(f"sudo xbps-install -y {pkgs}")


def is_void():
    return bool(shutil.which("xbps-install"))


def install_restricted(pkgs):
    "install restricted packages on VOID linux"
    install("xtools")
    if not isinstance(pkgs, list):
        pkgs = [pkgs]
    dst = "/data/repos/void-packages"
    if exists(dst):
        x(f"cd {dst} && git pull")
    else:
        x("sudo mkdir -p /data/repos")
        clone("https://github.com/void-linux/void-packages.git", dst)
    conf = "/data/repos/void-packages/etc/conf"
    x(f"touch {conf}")
    check_or_add("XBPS_ALLOW_RESTRICTED=yes", conf)
    x(f"cd {dst} && ./xbps-src binary-bootstrap")
    for pkg in pkgs:
        x(f"cd {dst} && ./xbps-src pkg {pkg} && xi {pkg}")


def update():
    "update system on VOID linux"
    x("sudo xbps-install -Su")


def clean():
    "clean up the system"
    # purge old kernels
    x("sudo vkpurge rm all")
    # clear package cache
    x("sudo xbps-remove -oO")


def reboot():
    x("sudo reboot")


def clone(repo, dst=None):
    "clone github repo"
    if not shutil.which("git"):
        install("git")
    if not dst:
        name = repo.rsplit("/", 1)[1].removesuffix(".git")
        dst = f"/tmp/{name}"
        x(f"rm -rf {dst}", check=False)
    if os.path.exists(dst):
        x(f"cd {dst} && git pull")
    else:
        x(f"git clone {repo} {dst}")
    return dst


def link_dots(dots_dir, names):
    "link dotfiles"
    dots_dir = os.path.expanduser(dots_dir)
    if not isinstance(names, list):
        names = [names]
    for name in names:
        x(f"ln -sf {dots_dir}/{name} ~/")


def link_configs(dots_dir, names):
    "link config files"
    dots_dir = os.path.expanduser(dots_dir)
    if not isinstance(names, list):
        names = [names]
    x("mkdir -p ~/.config")
    for name in names:
        x(f"ln -sf {dots_dir}/config/{name} ~/.config/")


def link_desktops(dots_dir, names):
    "link desktop files"
    dots_dir = os.path.expanduser(dots_dir)
    if not isinstance(names, list):
        names = [names]
    target = "~/.local/share/applications/"
    x(f"mkdir -p {target}")
    for name in names:
        x(f"ln -sf {dots_dir}/desktop/{name}.desktop {target}")


@task
def reconfigure_kernel(_args):
    "reconfigure kernel after hook added"
    ver = platform.release().rsplit(".", 1)[0]
    x(f"sudo xbps-reconfigure --force linux{ver}")


def q(msg):
    "print and quit"
    p(msg, "error", file=sys.stderr)
    sys.exit(1)


# source: https://stackoverflow.com/questions/287871/how-to-print-colored-text-to-the-terminal
def p(msg, fmt="debug", file=sys.stdout):
    "print colorized by status"
    begin = {
        "begin": "\x1b[0;30;43m",
        "debug": "\x1b[0m",
        "error": "\x1b[0;30;41m",
        "success": "\x1b[0;30;42m",
    }[fmt]
    end = "\x1b[0m"
    print(begin + msg + end, file=file)


def exists(path):
    "check if a path exists"
    return os.path.exists(os.path.expanduser(path))


def check_or_add(line, file):
    "check inf a line in a file exists"
    file = os.path.expanduser(file)
    line_exists = f"sudo grep -qxF '{line}' {file}"
    add_line = f"echo '{line}' | sudo tee -a {file}"
    x(f"{line_exists} || {add_line}")


def replace_line(pattern, replacement, file):
    regex = re.compile(pattern)
    lines = []
    path = os.path.expanduser(file)
    with open(path, "r") as f:
        for line in f:
            if regex.match(line):
                lines.append(replacement)
            else:
                lines.append(line.strip())
    tmp = ""
    with tempfile.NamedTemporaryFile(delete=False) as f:
        tmp = f.name
        f.write("\n".join(lines).encode("utf-8"))
    x(f"sudo mv {tmp} {file}")
    with open(path, "w") as f:
        f.write("\n".join(lines))


def has_disk(uuid):
    "check if current system has a disk with given uuid"
    return bool(x_output(f'blkid | grep "{uuid}" && echo true'))


def parse_args(argv):
    "parse command line arguments"
    parser = argparse.ArgumentParser(
        prog=argv[0], formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("task", choices=TASKS)
    parser.add_argument("-ssid", help="SSID for wifi")
    parser.add_argument("-pw", help="WPA/WPA(2) key for wifi")
    parser.add_argument(
        "--dots_dir",
        default=os.path.expanduser("~/conf/dots"),
        help="root directory for dotfiles",
    )
    parser.add_argument(
        "--font_url", help="source: https://www.nerdfonts.com/font-downloads"
    )
    parser.add_argument("--hostname", help="system hostname")
    parser.add_argument("--keyboard", default="us", help="keyboard country")
    parser.add_argument("--locale", default="en_US.UTF-8", help="system locale")
    parser.add_argument(
        "--timezone", default="America/Los_Angeles", help="time zone for system"
    )
    parser.add_argument("--username", help="user to create")
    parser.add_argument(
        "--groups",
        default=[
            "audio",
            "cdrom",
            "floppy",
            "input",
            "kvm",
            "network",
            "optical",
            "storage",
            "users",
            "video",
            "wheel",
            "xbuilder",
        ],
        help="user groups",
    )
    parser.add_argument(
        "--data_disk_uuid", help="disk partition UUID for mounting to /data in fstab"
    )
    return parser.parse_args(argv[1:])


def handler(_signal_received, _frame):
    "handle signals from user or system"
    print("\n\nAdios!")
    sys.exit(0)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, handler)
    ARGS = parse_args(sys.argv)
    globals()[ARGS.task](ARGS)
