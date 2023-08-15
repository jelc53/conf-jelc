source ~/.config/eww/eww.nu

# special env for raptor maps (2023-05-15)
if 'julian' in (whoami) {
  $env.CFLAGS = "-I$(brew --prefix openssl)/include -I$(brew --prefix zlib)/include"
  $env.LDFLAGS = "-L$(brew --prefix openssl)/lib -L$(brew --prefix zlib)/lib"
  $env.DOCKER_DEFAULT_PLATFORM = "linux/amd64"
}

# CONFIG
$env.config = {
  show_banner: false
  float_precision: 2
  use_ansi_coloring: true
  edit_mode: vi # emacs, vi
  ls: {
    use_ls_colors: true # use the LS_COLORS environment variable to colorize output
    clickable_links: true # enable or disable clickable links. Your terminal has to support links.
  }
  rm: {
    always_trash: true # always act as if -t was given. Can be overridden with -p
  }
  cd: {
    abbreviations: true # allows `cd s/o/f` to expand to `cd some/other/folder`
  }
  table: {
    mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
    index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
    trim: {
      methodology: wrapping # wrapping or truncating
      wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
      truncating_suffix: "..." # A suffix used by the 'truncating' methodology
    }
  }
  history: {
    max_size: 10000 # Session has to be reloaded for this to take effect
    sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
    file_format: "plaintext" # "sqlite" or "plaintext"
  }
  completions: {
    case_sensitive: false # set to true to enable case-sensitive completions
    quick: true  # set this to false to prevent auto-selecting completions when only one remains
    partial: true  # set this to false to prevent partial filling of the prompt
    algorithm: "prefix"  # prefix or fuzzy
    external: {
      enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
      max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
      completer: null # check 'carapace_completer' above as an example
    }
  }
  filesize: {
    metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
    format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
  }
  # KEYBINDINGS
  keybindings: [
    {
      name: find_file_by_name
      modifier: control
      keycode: char_f
      mode: vi_insert
      event: {
        send: executehostcommand,
        cmd: 'edit (fd ".+" . /data -H --color=always
        | fzf +m --select-1 --preview "bat --style=numbers --color=always {}"
        | str trim)'
      }
    }
    {
      name: reload_config
      modifier: control
      keycode: char_r
      mode: [ emacs vi_insert vi_normal ]
      event: [
        { edit: clear }
        {
           edit: insertString
           value: $"source ($nu.env-path); source ($nu.config-path)"
        }
        { send: Enter }
      ]
    }
    {
      name: find_file_by_name_ctrl_p
      modifier: control
      keycode: char_p
      mode: vi_insert
      event: {
        send: executehostcommand,
        cmd: 'edit (fd ".+" . /data -H --color=always
        | fzf +m --select-1 --preview "bat --style=numbers --color=always {}"
        | str trim)'
      }
    }
    {
      name: find_file_by_regex
      modifier: control
      keycode: char_s
      mode: vi_insert
      event: {
        send: executehostcommand,
        cmd: "edit (
        fzf --bind 'change:reload:rg --line-number --no-heading --smart-case --color=always {q} . /data/repos'
        --preview '~/.config/nushell/scripts/preview.nu {}' +m --select-1
        | cut -d: -f1
        | str trim)"
      }
    }
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: emacs # Options: emacs vi_normal vi_insert
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: shift
      keycode: backtab
      mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
      event: { send: menuprevious }
    }
    {
      name: history_menu
      modifier: control
      keycode: char_h
      mode: vi_insert
      event: {
        until: [
          { send: menu name: history_menu }
          { send: menupagenext }
        ]
      }
    }
    {
      name: history_previous
      modifier: control
      keycode: char_z
      mode: vi_normal
      event: {
        until: [
          { send: menupageprevious }
          { edit: undo }
        ]
      }
    }
  ]
}

# COMMANDS

$env.PROMPT_COMMAND = { || left-prompt }

def left-prompt [] {
  [
    # H:M time
    (style (date now | date format "%H:%M") g)
    # user@host
    (style $"($env.USER)@(hostname | str trim)" rb)
    # git branch: red if dirty, white if clean
    (if (v exists) { if (v dirty) { (style (v branch) r) } else { (style (v branch) w) } } else { '' }),
    # short home
    (style (pwd | str replace '/\w*home/\w+' '~' | str trim) cb)
    # prompt char
    $"(char newline)λ "
  ] | str join ' ' | str replace -a '  ' ' '
}

# format text with a given style
def style [
  text: string   # text to format
  style: string  # style of string
] {
  $"(ansi $style)($text)(ansi reset)"
}

# install system package
def install [...packages] { sudo xbps-install -y $packages }

# install history
def ihistory [] { xilog }

# remove system package
def remove [...packages] { sudo xbps-remove $packages }

# service related functions
def service [] { service list }

# service status
def "service status" [name: string] { sudo sv status $name }

# service restart
def "service restart" [name: string] { sudo sv restart $name }

# service up
def "service up" [name: string] { sudo sv up $name }

# service down
def "service down" [name: string] { sudo sv down $name }

# list available services
def "service list" [] { ls /etc/sv/ | get name | path basename }

# list active services
def "service active" [] { ls /var/service | get name | path basename }

# enable service
def "service enable" [name: string] { sudo ln -sf $"/etc/sv/($name)" /var/service/  }

# disable service
def "service disable" [name: string] { sudo rm $"/var/service/($name)" }

# list file types in cwd
def types [] {
  ls | each { |f| file $f.name | parse '{name}:{type}' }
}

# search system packages
def search [
  pattern: string,
] { xlocate -S; xlocate $pattern }

# preview 
def preview [] {}

# preview for search command
def "preview search" [
  result: string  # input
] {
  let p = ($result | parse '{file}:{line}:{match}')
  let file = ($p | get file.0)
  let line = ($p | get line.0)
  bat --style=numbers --color=always --line-range $"($line):" --highlight-line $line $file
}

# edit a config file
def cfg [] { cfg nu }

# edit init.nu
def "cfg nu" [] { cd ~/.config/nushell; hx config.nu; cd - }

# edit hx file
def "cfg hx" [] { cd ~/.config/helix/; hx config.toml; cd - }

# edit bspwmrc
def "cfg bspwm" [] { cd ~/.config/bspwm; hx bspwmrc; cd -; }

# edit eww config
def "cfg eww" [] { cd ~/.config/eww; hx eww.yuck; cd -; }

# tex commands
def tex [] {}

# tex install
def "tex install" [
  ...packages  # package names
] { sudo tlmgr install $packages }

# tex search
def "tex search" [
  keyword: string
] { tlmgr show $keyword }

# tex remove
def "tex remove" [
  ...packages  # package names
] { sudo tlmgr remove $packages }

# tex update
def "tex update" [] { sudo tlmgr update --all }

# packer remove packages
def prm [
  ...rest: string # packages
] {
  # TODO: update once this is merged https://github.com/wbthomason/packer.nvim/pull/335
  cd ~/.local/share/nvim/site/pack/packer/opt
  $rest | each { |pkg| do -i { rm -rf $pkg } } | flatten
  cd ../start
  $rest | each { |pkg| do -i { rm -rf $pkg } } | flatten
}

# spotify tui
def spt [] {
  if (ps | where name == 'spotifyd' | length) == 0 {
    ~/.config/rofi/spotifyd.sh
  }
  spotify-tui
}

# adjust backlight
def light [] {
    busctl --expect-reply=false --user call org.clight.clight /org/clight/clight org.clight.clight Capture "bb" false false
}

# set things
def set [] {}

# turn on dpms
def "set dpms on" [] { xset s on +dpms }

# turn off dpms
def "set dpms off" [] { xset s off -dpms }

# set backlight
def "set light" [
  value: int,  # 1-100
] {
  let max_path = "/sys/class/backlight/intel_backlight/max_brightness"
  let path = "/sys/class/backlight/intel_backlight/brightness"
  if $value > 0 and $value <= 100 {
    # NOTE: /sys/class/backlight/intel_backlight/max_brightness
    # contains the max brightness value, i.e. 2056, divide this by 100
    # to increment in terms of percents
    # this also requires the user to be in the video group,
    # and the correct udev rules to be setup
    let v = ($value * (open $max_path | lines | get 0 | into int) / 100 | into int)
    echo $v | into string | save -f $path
  }
  if $value < 1 or $value > 100 {
    echo "value must be an integer between 1 and 100, inclusive"
  }
}

# toggle stuff
def toggle [] {}

# toggle fullscreen, hiding all background windows
def "toggle fullscreen" [] {
  # TODO(danj): bug in ~ expansion with raw nu script
  bash -c "bspc node -t '~fullscreen'"
  if (is fullscreen) {
    bspc query -N -n .local.!fullscreen | lines | each { |id| bspc node $id -g hidden=on }
  } else {
    bspc query -N -n .local.hidden | lines | each { |id| bspc node $id -g hidden=off }
  }
}

# toggle light/dark theme
def "toggle theme" [] {
  if (ls -l ~/imgs/background.png | where target =~ "dark" | is-empty) {
    set theme dark
  } else {
    set theme light
  }
}

# set theme based on an image
def "set theme" [
  name: string # theme name
  --img: string # path to image
  --rofi: string # path to image for rofi
] {
  if ($img != $nothing) { convert ($img | path expand) ($"~/imgs/($name).png" | path expand); wal -c }
  if ($rofi != $nothing) { set rofi $rofi }
  wal -i ($"~/imgs/($name).png" | path expand)
  ln -sf ($"~/imgs/($name).png" | path expand) ~/imgs/background.png
  ln -sf ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
  ln -sf ~/.cache/wal/zathurarc ~/.config/zathura/zathurarc
  ln -sf ~/.cache/wal/colors.scss ~/.config/eww/colors.scss
  bspc wm -r
  pywalfox update
}

# set rofi image
def "set rofi" [
  img: string # path to image for rofi
] {
  convert $img -gravity center -crop 4:3 -resize 400x300 $"~/imgs/rofi.png"
}

# set default app (listed in /usr/share/applications) for a file
def "set default" [
  file: string  # file, i.e. file.png
  app: string   # app, i.e. org.gnome.gThumb.desktop
] { xdg-mime default $app (xdg-mime query filetype $file | str trim) }

# get things
def gett [] {}

# get backlight
def "gett light" [] {
  let max_path = "/sys/class/backlight/intel_backlight/max_brightness"
  let path = "/sys/class/backlight/intel_backlight/brightness"
  (open $path | lines | get 0 | into int) / (open $max_path | lines | get 0 | into int) * 100 | into int
}

def "light inc" [] {
  let v = (gett light)
  set light ($v + 2)
}

def "light dec" [] {
  let v = (gett light)
  set light ($v - 1)
}

# lock
def lock [] { bspc node -t ~fullscreen; neo }

# unlock
def unlock [] { bspc node -t ~fullscreen }

# show what CPU processes are popping off
def wut [] { ps | where cpu > 10 }

# show symbolic link targets
def links [] { ls -la | where target != "" | select name target }

# disk space usage helper
def disk [
  path: string  # path
  n: int = 5 # top n
] {
  du $path
  | get directories.0
  | select path physical
  | str replace -a $"($path)/*" "" path
  | sort-by -r physical
  | first $n
}

# test if inside a tmux session
def in-tmux [] { (do -i { $env.TMUX }) != $nothing }

# tmux helper function
def tm [
  --name (-n): string  # session name
] {
  let action = (if (in-tmux) { "switch-client" } else { "attach-session" })
  if ($name | is-empty) {
    # TODO: no server running on /tmp/tmux-1000/default to stderr
    let session = (do -i { tmux list-sessions -F '#{session_name}' | lines | first })
    if ($session == $nothing) {
      if (v exists) {
        let $repo = (v name)
        tmux new-session -d -s $repo; tmux $action -t $repo
      } else { tmux new-session }
    } else { tmux $action -t $session }
  } else {
    if not (tm exists $name) {
      tmux new-session -d -s $name
    }
    tmux $action -t $name
  }
  clear
}

# test if tmux session exists
def "tm exists" [
  name: string  # session name
] {
  (tm ls | lines | where $it == $name | length) > 0 
}

# list tmux sessions
def "tm ls" [] { tmux list-sessions -F '#{session_name}' }

# edit a given path
def-env edit [
  path: string  # path to edit
] {
  let path = ($path | str trim | path expand)
  let dir = ($path | path dirname)
  let file = ($path | path basename)
  let root = if (is file $path) { $dir } else { $path }
  cd $root
  if (is file $path) {
    if (in-tmux) {
      hx $file
    } else if (v exists) {
      cd (v root)
      let repo = (v name)
      let cmd = $"cd ($dir); hx ($file); ($env.SHELL)"
      if (tm exists $repo) {
        tmux new-window -t $repo $cmd
        tmux attach-session -t $repo
      } else {
        tmux new-session -s $repo $"cd ($dir); hx ($file); ($env.SHELL)"
      }
    } else {
      tmux new-session $"cd ($dir); hx ($file); ($env.SHELL)"
    }
  }
}

# tests for file types
def is [ext: string, path: path] {
  ($path | path parse | get extension) == $ext
}

# tests for file status
def "is file" [ path: path ] { ($path | path type) == file }

# tests for directory status
def "is dir" [ path: path ] { ($path | path type) == dir }

# tests to see if fullscreen
def "is fullscreen" [] {
  (bspc query -N -n .local.fullscreen | complete | get exit_code) == 0
}

# sync commands
def sync [
  ...rest
] { rsync $rest }

# sync current directory to location
def "sync to" [ 
  location: string  # user@host:dir
] { rsync -avzhe ssh $location . }

# sync location to current directory
def "sync from" [
  location: string  # user@host:dir
] { rsync -chavzP --stats $location . }

# rclone gdrive commands
def gdrive [] {}

# rclone mount gdrive at ~/gdrive
def "gdrive mount" [] {
  do -i { gdrive unmount }
  rclone mount gdrive: /gdrive --daemon --vfs-cache-mode full
}

def "gdrive mount shared" [] {
  do -i { gdrive unmount }
  rclone mount gdrive: /gdrive --daemon --vfs-cache-mode full --drive-shared-with-me 
}

# rclone unmount gdrive at ~/gdrive
def "gdrive unmount" [] { fusermount -uz /gdrive }

# sync /data/pdfs to gdrive:/pdfs
def "gdrive sync pdfs" [] {
  # sync from remote to local, no deleting
  rclone copy gdrive:pdfs /data/pdfs
  # sync from local to remote, no deleting
  rclone copy /data/pdfs gdrive:pdfs
}

# rclone gdrive move
def "gdrive move" [
  src: string, # source path
  dst: string, # destination dir
] { rclone move $src $"gdrive:($dst)" -v }

# rclone gdrive sync
def "gdrive sync" [
  src: string, # source path
  dst: string, # destination dir
] { rclone sync $src $"gdrive:($dst)" -v }

# rclone gdrive copy to gdrive:scratch
def "gdrive scratch" [
  --path (-p): string, # copy $path (file or dir) to gdrive:scratch
  --up (-u), # copy ~/scratch to gdrive:scratch
  --down (-d), # copy gdrive:scratch to ~/scratch
  --clear (-c): # clear gdrive:scratch
] {
  if not ($path | is-empty) { rclone copy $path gdrive:scratch }
  if $up { rclone copy ~/scratch gdrive:scratch }
  if $down { rclone copy gdrive:scratch ~/scratch }
  if $clear { rclone delete --rmdirs gdrive:scratch }
}

# create a tarball
def tgz [
  dir: string  # source directory
] { tar chvzf $"($dir).tgz" $dir }

# unpack a tarball
def "tgz u" [
  path: string  # path to unpack
] { tar xvzf $path }

# print a photo
def print-photo [
  image: string  # image to print
] { convert $image png:- | lp -o media="4x6.Borderless" - }

# wifi shorthand for nmcli
def wifi [] {}

# turn on wifi
def "wifi on" [] {
  nmcli radio wifi on
}

# turn off wifi
def "wifi off" [] {
  nmcli radio wifi off
}

# restart wifi adapter
def "wifi restart" [] {
  nmcli radio wifi off
  sleep 3sec
  nmcli radio wifi on
}

# list wifi networks
def "wifi list" [] {
  nmcli device wifi list
}

# connect to wifi network
def "wifi connect" [ssid: string, password?: string] {
  if ($password == null) {
    nmcli device wifi connect $ssid
  } else {
    nmcli device wifi connect $ssid password $password
  }
}

# disconnect from wifi network
def "wifi disconnect" [ssid: string] {
  nmcli device disconnect $ssid
}

# get wifi gateway
def "wifi gateway" [] {
  ip route
  | parse -r 'default via (?P<gateway>\S+)\s+'
  | get gateway.0
}

# get wifi state
def "wifi state" [] {
  nmcli device
  | lines
  | skip 1
  | parse -r '(?P<device>\S+)\s+(?P<type>\S+)\s+(?P<state>\S+)\s+(?P<connection>.*)'
  | where connection !~ '--'
}

# connect to phone hotspot
def "wifi phone" [ssid: string = 'Motoko Mobile'] {
  nmcli device wifi rescan ssid $ssid
  nmcli device wifi connect $ssid
}

# vpn commands
def vpn [] {}

# vpn connect
def "vpn connect" [
  name: string, # vpn name
] { nmcli --ask con up $name }

# vpn disconnect
def "vpn disconnect" [
  name: string, # vpn name
] { nmcli con down $name }

# connect to stanford vpn
def "vpn on" [] { vpn connect stanford }

# disconnect from stanford vpn
def "vpn off" [] { vpn disconnect stanford }

# copy file to clipboard
def fcp [
  path: string  # path
] { cat $path | xclip -sel clip }


# VERSION CONTROL

# version control system commands
def v [
  repo: string
] { git clone $repo }

# clone repo from GITHUB_USER
def "v user" [
  repo: string
] { git clone $"git@github.com:($env.GITHUB_USER)/($repo)" }

# clone repo from the Stanford Computational Policy Lab
def "v scpl" [
  repo: string
] { git clone $"git@github.com:stanford-policylab/($repo)" }

# clone repo from Big Local News
def "v bln" [
  repo: string
] { git clone $"git@github.com:biglocalnews/($repo)" }

# add all files
def "v add" [] { do -i { git add --all } }

# get current branch
def "v branch" [] { do -i { git rev-parse --abbrev-ref HEAD | str trim } }

# commit changes
def "v commit" [message: string] { git commit -m $message }

# checkout a branch
def "v co" [ branch: string ] { git checkout $branch }

# view diff (changes)
def "v diff" [ ...rest ] { do -i { git diff $rest } }

# view historical changes (patches)
def "v hist" [ path: path ] { git log -p -- $path }

# test if branch is dirty
def "v dirty" [] { (do -i { git status --porcelain } | length) > 0 }

# test if in a vcs repository
def "v exists" [] { v status | complete | get stderr | is-empty }

# move/rename a file in vcs
def "v mv" [ from: string, to: string ] { git mv $from $to }

# get the name of current repository
def "v name" [] { basename (v root) | str trim }

# push changes
def "v push" [] { ^git push }

# squash commits
def "v squash" [] {
  git rebase --root -i
  ^git push origin (v branch) --force
}

# remove file from vcs
def "v rm" [ file: string ] { git rm -f $file }

# get root of repository
def "v root" [] { git rev-parse --show-toplevel | str trim }

# view status
def "v status" [] { do -i { git status } }

# update branch
def "v update" [] { git pull --rebase }

# add all files, commit message, and push changes
def "v all" [ message: string ] {
  v add
  v commit $message
  v push
}

# create branch
def "v new" [
  branch: string
] { git checkout -b $branch; git push --set-upstream origin $branch }

# delete branch
def "v delete" [
  branch: string
] { git branch -d $branch; git push origin --delete $branch }

# merge branch into current branch
def "v merge" [
  branch: string
] { git merge --squash $branch }

# generate a pdf from docx, tex, dot, etc
def pdf [
  path: path
] {
  if (is tex $path) {
    let p = (change_ext $path tex pdf)
    let base = ($p | path dirname)
    let file = ($p | path basename)
    latexmk $path
  } else if (is docx $path | is pptx $path) {
    libreoffice --headless --convert-to pdf $path
  } else if (is dot $path) {
    let out = (change_ext $path dot pdf)
    dot $"-Tpdf" $path -o $out
  }
}

def "pdf watch" [
  path: string
] {
  let p = (change_ext $path tex pdf)
  let base = ($p | path dirname)
  let file = ($p | path basename)
  let build_path = ($base | path join build $file)
  latexmk $path; bash -c $"xdg-open ($build_path) &"
  watch $path { || latexmk $path }
}

def "pdf search" [
  pattern: string
] {
  let v = (do { rg -tpdf -ila $pattern ~/Zotero ~/pdfs } | complete | get exit_code)
  if ($v > 0) {
    pdfgrep $pattern ~/Zotero/* ~/pdfs/*
  } else {
    rg -tpdf -ila $pattern ~/Zotero ~/pdfs
  }
}

def "pdf search here" [
  pattern: string
] {
  let v = (do { rg -tpdf -ila $pattern } | complete | get exit_code)
  if ($v > 0) {
    pdfgrep $pattern *
  } else {
    rg -tpdf -ila $pattern
  }
}

def "pdf merge" [
  out: string # out file name
  ...pdfs: string # pdfs to combine
] {
  gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite $"-sOutputFile=($out)" $pdfs
}

# crop and send pdf to kindle
def "pdf kindle" [
  pattern: string,
  bbox?: string,
] {
  let paths = (fd -p -t f $pattern ~/pdfs ~/Zotero/storage ~/scratch | lines)
  let n = ($paths | length)
  if $n == 0 {
    "No results!"
  } else if $n == 1 {
    let src = ($paths | first)
    let dst = $"/run/media/jelc/Kindle/documents/($src | path basename)"
    if ($bbox == null) {
      pdfcrop --margins 5 $src $dst
    } else {
      pdfcrop --bbox $bbox $src $dst
    }
  } else {
    $paths
    | path parse
    | select parent stem
    | update parent { |row| $row.parent | path basename }
  }
}

# convert to a csv
def csv [
  path: path
] {
  if (is xls $path) {
    let out = (change_ext $path xls pdf)
    ssconvert --export-file-per-sheet $path $out
  } else if (is xlsx $path) {
    let out = (change_ext $path xls pdf)
    ssconvert --export-file-per-sheet $path $out
  }
}

# convert to gcode
def gcode [path: path] { prusa-slicer -g $path }

# change file extension
def change_ext [
  path: string,
  old_ext: string,
  new_ext: string
] {
  $path
  | path parse -e $old_ext
  | update extension { || $new_ext }
  | path join
}

# format disk commands
def fmt [] {}

# show drives
def "fmt show" [] { lsblk }

# unmount a device
def "fmt unmount" [
  partition: string  # partition, i.e. sda1, sde2
] { udisksctl unmount -b $"/dev/($partition)" }

# format external drive
def "fmt clean" [
  dev: string  # device, i.e. sda, sde
] { sudo mkfs.vfat -I $"/dev/($dev)" }

# dd iso to dev
def "fmt flash" [
  iso: path  # iso path
  dev: string  # device, i.e. sda, sde
] { sudo dd $"if=($iso)" $"of=/dev/($dev)" bs=1M status=progress oflag=direct }


# clean files older than duration
def clean [
  d: duration  # i.e. 5hr, 1day, 1wk
] {
  ls
  | where modified < ((date now) - $d)
  | each { |f| rm -r $f.name }
  | flatten
}

# system commands, i.e. update, clean
def system [] {}

# update system
def "system update" [] {
  sudo xbps-install -Su
  cargo install nu --features=dataframe
}


# clean system
def "system clean" [] {
  # remove old kernels
  sudo vkpurge rm all
  # clear package cache
  sudo xbps-remove -oO
  # clear user cache, except pypoetry and renv
  ls ~/.cache | where name !~ 'pypoetry|R' | each { |v| rm -rf $v.name }
  # empty trash
  rm -rf ~/.local/share/Trash/*
  # set theme because cache was cleared
  set theme light
}

# clean up pypoetry virtualenvs and packages
def "system clean poetry" [] {
  rm -rf ~/.cache/pypoetry
}

# estimated time of death (battery)
def etd [] {
  upower -i /org/freedesktop/UPower/devices/battery_BAT0
  | parse -r '\s*(?P<key>[^:]+):\s*(?P<value>.*)'
  | where key in [state rate empty percentage 'time to full']
  | where value != "0 Wh"
}

# start X with given display setup
def-env x [
  --xorg_conf: string # name, as in /etc/X11/xorg.conf.<name>
  --wm_conf: string # name, as in ~/.config/.bspwmrc/<hostname>/<wm_conf>.sh
  --bg: path # path to background image
] {
  $env.WM_CONF = $wm_conf
  if ($bg != $nothing) { set theme default --img $bg }
  if (ps | where name =~ 'Xorg' | length) > 0 {
    bash -c "~/.config/bspwm/bspwmrc > /dev/null 2>&1"
  } else {
    x config -n $xorg_conf
    startx
  }
}

# if a config exists, use it; otherwise, use default [none]
def "x config" [
  --name (-n): string # name, as in /etc/X11/xorg.conf.<name>
] {
  let xconfig = '/etc/X11/xorg.conf'
  let target = $"/etc/X11/xorg.conf.($name)"
  if ((readlink -f $xconfig | str trim) != $target) {
    if ($xconfig | path exists) {
      sudo rm $xconfig
    }
    if ($target | path exists) {
      sudo ln -s $target $xconfig
    }
  }
}

# show gpu status
def "gpu status" [] {
  nvidia-smi
}

# show loaded nvidia kernel modules
def "gpu nvidia" [] { lsmod | grep nvidia }

# show number of gpu clients
def "gpu nclients" [] {
   gpu nvidia | lines | first | parse -r '.*(?P<n>\d+)$' | get n | get 0
}

# show gpu clients
def "gpu clients" [] { lsof | grep /dev/nvidia }

# show graphics providers
def "gpu providers" [] { xrandr --listproviders }

# show monitors
def "gpu monitors" [] { xrandr --listmonitors }

# log out
def logout [] { bspc quit }

# bluetooth device commands
def bt [] {
  [
    ["name", "device", "address"];
    ["BTunes M50X/5", "at", "00:18:91:8C:77:21"]
    ["Powerbeats Pro", "beats", "88:B9:45:06:28:03"]
    ["JBL Flip 5", "flip", "B8:F6:53:A0:DF:2C"]
    ["Echo Dot", "echodot", "48:B4:23:72:C7:65"]
    ["Xbox Controller", "xbox", "A8:8C:3E:3E:E2:B0"]
  ]
}

# bluetooth scan
def "bt scan" [] {
  bluetoothctl power on
  bluetoothctl scan on
}

# bluetooth devices
def "bt devices" [] {
  bluetoothctl power on
  bluetoothctl devices
}

# bluetooth pair
def "bt pair" [
  address: string
] {
  bluetoothctl power on
  bluetoothctl pair $address 
}

# bluetooth connect
def "bt connect" [
  --device (-d): string  # at (audio-technica), beats, flip
] {
  let address = (bt | where device == $device | get address)
  bluetoothctl power on
  bluetoothctl connect $address
}

# bluetooth disconnect
def "bt disconnect" [
  --device (-d): string  # at (audio-technica), beats, flip
] {
  let address = (bt | where device == $device | get address)
  bluetoothctl disconnect $address
  bluetoothctl power off
}

# listen to youtube
def yt [
  url: string, # youtube share link url
] { ~/.config/rofi/youtube_audio.sh $url }
# ] { bash -c $"~/.config/rofi/youtube_audio.sh ($url)" }

# stop listening to youtube
def "yt stop" [] {
  ps -l | where command =~ 'mpv --no-video' | each { |proc| kill $proc.pid }
}

# hotspot commands
def hotspot [] {}

# configure a new hotspot
def "hotspot create" [] { sudo wihotspot }

# hotspot status
def "hotspot status" [] {
  if (ps | where name == 'create_ap' | length) > 0 { "on" } else { "off" }
}

# start hotspot configured by /etc/create_ap.conf
def "hotspot start" [] {
  if (hotspot status) == "off" {
    sudo ~/.config/rofi/hotspot_start.sh
  }
}

# stop hotspot
def "hotspot stop" [] {
  if (hotspot status) == "on" {
    sudo pkill create_ap
  }
}

# spit a quote out
def quote [] {
  if ("/data/repos/quotes" | path exists) {
    python /data/repos/quotes/memorize.py
  }
}

def "quote edit" [] {
  cd /data/repos/quotes
  vim README.md
  vx "adding quote"
  cd -
}

def ted [] {
  cd /data/repos/quotes
  vim ted.txt
  vx "adding ted tidbit"
  cd -
}

# connect to an sc compute node from head sc node
def compute [] {
  srun --partition=sc-quick --nodelist=scq2 --gres=gpu:1 --cpus-per-task 8 --mem 40GB --pty bash
}

# connect to thrun lab servers
def thrun [
  --node (-n): int = 1, # node id
  --gpu (-g): int = 1, # number of gpus
  --cpu (-c): int = 8,  # number of cpus
  --mem (-m): int = 40, # GB of memory
] {
  srun --account=thrun --partition=thrun --nodelist $"scq($node)" --gres $"gpu:($gpu)" --cpus-per-task $cpu --mem $"($mem)GB" --pty bash
}

def "thrun use" [] {
  pestat -G | grep -Ei "Hostname|Use/Tot|scq"
}

# kernel functions
def "kernel" [] {}

# save kernel perams
def "kernel params" [output: path] {
  cat /proc/config.gz | gunzip | save $output
}

# host wikipedia locally
def "wiki" [] {
  bash -c "kiwix-serve -p 8080 /data/kiwix/wikipedia_*.zim &"
  sleep 1sec
  firefox localhost:8080
}

def "wiki kill" [] { pkill kiwix-serve }

# alias for docker
def dk [...rest] { docker $rest }

# start a one of bash docker container
def "dk once" [
  distro: string # name of distro, i.e. ubuntu, alpine, bash, etc
] { docker run -it --rm $distro }

# ALIASES 
alias farm = ssh farm
alias R = radian
alias define = dict
alias above = bspc node focused.floating --layer above
alias ipy = ipython
alias o = xdg-open
alias pk = ranger
alias tree = ^tree
alias kb = xmodmap ~/.Xmodmap
alias va = v add
alias vb = v branch
alias vd = v diff
alias vg = v user
alias vh = v hist
alias vp = v push
alias vq = v squash
alias vs = v status
alias vu = v update
alias vx = v all
alias g = gdrive
alias gx = gdrive scratch
alias lofi = yt "https://youtu.be/5qap5aO4i9A"
alias nofi = yt stop
alias at = bt connect -d at
alias atd = bt disconnect -d at
alias beats = bt connect -d beats
alias beatsd = bt disconnect -d beats
alias xbox = bt connect -d xbox
alias xboxd = bt disconnect -d xbox
alias flip = bt connect -d flip
alias flipd = bt disconnect -d flip
alias echodot = bt connect -d echodot
alias echodotd = bt disconnect -d echodot
alias cfgh = cfg hx
alias cfgb = cfg bspwm
alias cfge = cfg eww
alias nbk = jupyter notebook
alias cal = ^cal
alias docked = x --wm_conf docked --xorg_conf docked
alias m14 = x --wm_conf m14
alias wb = x --wm_conf wb  # wallenberg 433C
alias wbm = x --wm_conf wbm # wallenberg monitor
alias g117 = x --wm_conf green_117
alias icmetv = x --wm_conf icme_tv
alias icmem = x --wm_conf icme_monitor
alias icmec = x --wm_conf icme_conf
alias jjl = x --wm_conf jojos_left
alias jjr = x --wm_conf jojos_right
alias mobile = x --wm_conf mobile
alias nebula = x --wm_conf nebula
alias tls = tm ls
alias kk = pdf kindle
alias s = pdf search
alias sh = pdf search here
alias gg = gitui
alias js = bash -c "julia --startup-file=no -e 'using DaemonMode; serve()' &"
alias jc = julia --startup-file=no -e "using DaemonMode; runargs()"

# spit out a quote
quote
