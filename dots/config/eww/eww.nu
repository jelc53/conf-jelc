#!/usr/bin/env nu

# open configuration program
def configure [] {}

# eww workspaces literal
def "workspaces" [] {
  let ws = (workspaces info)
  [
    '(box',
    ':class "bar group workspaces"',
    ':orientation "vertical"',
    ($ws | each { |w|
      $"\(button :onclick 'bspc desktop -f ($w.id)' :class '(class ($w))' '($w.symbol)'\)"
    }),
    ')'
  ] | flatten | str join " "
}

# bspwm workspace information
def "workspaces info" [] {
  let occupied = (bspc query -D -d .occupied --names | lines | into int)
  let active = (bspc query -D -d focused --names | into int)
  [
    [id, symbol];
    [1, 一],
    [2, 二],
    [3, 三],
    [4, 四],
    [5, 五],
    [6, 六],
    [7, 七],
    # [8, 八],
    # [9, 九],
    # [10, 十],
  ] | each {|w|
    {
      id: $w.id,
      symbol: $w.symbol,
      occupied: ($w.id in $occupied),
      active: ($w.id == $active),
    }
  }
}

# add css classes
def class [v] {
  [
    (if ($v.active) { "active" } else { "inactive" }),
    (if ($v.occupied) { "occupied" } else { "unoccupied" })
  ] | str join " "
}


# launch apps
def launch [] {}
def "launch launcher" []  {
  rofi -show combi -modi combi
}
def "launch terminal" [] { PWD=$env.HOME alacritty }
def "launch terminal floating" [] {
  bspc rule -a Alacritty -o state=floating center=true rectangle=800x600+0+0
  PWD=$env.HOME alacritty
}
def "launch files" [] { PWD=/data/scratch Thunar }
def "launch todos" [] {
  bspc rule -a Alacritty -o state=floating center=true rectangle=800x600+0+0
  alacritty -e hx ~/todos.md
}
def "launch todos secondary" [] {
  alacritty -e hx ~/todos-secondary.md
}
def "launch firefox" [] { firefox }
def "launch spotify" [] { spotify }
def "launch calendar" [] { firefox calendar.google.com }

# show todos
def todos [] {
  open ~/todos.md
  | from tsv --noheaders
  | rename todos
  | table
  | ansi strip
  | str replace -a '\n' ' '
}

# battery functions
def battery [] {
  upower -i /org/freedesktop/UPower/devices/battery_BAT0
  | parse -r '\s*(?P<key>[^:]+):\s*(?P<value>.*)'
  | where value != "0 Wh"
}

# battery percent
def "battery percent" [] {
  battery
  | where key == percentage
  | get value
  | parse -r '(?<value>\d+)%'
  | get value.0
  | into int
}

# battery watts
def "battery watts" [] {
  battery
  | where key == 'energy-rate'
  | get value.0
  | parse -r '(?<watts>\d+.\d?).*'
  | get watts.0
}

# battery charge
def "battery charge" [] {
  if (battery charged) {
    [[value, units]; [0, Hours]]
  } else {
    battery
    | where key == (if (battery charging) {
        "time to full"
      } else {
        "time to empty"
      })
    | get value.0
    | parse -r '(?<value>\d+.\d)\d* (?<units>\w+)'
  }
}

# battery charge value
def "battery charge value" [] {
  battery charge | get value.0
}

# battery charge units
def "battery charge units" [] {
  battery charge | get units.0 | str capitalize
}

# battery state
def "battery state" [] {
  battery | where key == state | get value.0
}

# battery fully charged
def "battery charged" [] {
  (battery state) in ["fully-charged", "pending-charge"]
}

# battery discharging
def "battery charging" [] {
  (battery state) == "charging"
}

# notify about low battery
def "battery notify" [] {
  let lock = "/tmp/low_battery.lock"
  let is_locked = ($lock | path exists)
  if ((battery charging) or (battery charged)) {
    do -i { rm $lock }
  } else if (((battery percent) < 11) and (not is_locked)) {
    touch $lock
    notify-send 'Critical Battery' 'Plug it in kid'
  }
}

# battery icon
def "battery icon" [] {
  if ((battery | get value.0) == '(null)' or (battery charging) or (battery charged)) {
    ''
  } else {
    [
      [level, icon];
      [90, 󰂂],
      [80, 󰂁],
      [70, 󰂀],
      [60, 󰁿],
      [50, 󰁾],
      [40, 󰁽],
      [30, 󰁼],
      [20, 󰁻]
      [10, 󰁺],
      [0, 󱃍],
    ]
    | where level <= (battery percent)
    | get icon.0
  }
}

# network functions
def network [] {}

# configure network using nmtui
def "configure network" [] {
  bspc rule -a Alacritty -o state=floating; alacritty -e nmtui
}

# return whether connected to current network
def "network connected" [] {
  (nmcli | rg ' connected' | complete | get exit_code) == 0
}

# return network icon
def "network icon" [] {
  if (network connected) {
    '󰖩'
  } else {
    '󰖪'
  }
}

# return network name
def "network name" [] {
  if (network connected) {
    $"'(nmcli
    | rg ' connected'
    | parse -r '.* connected to (?<network>.*)'
    | get network.0)'"
  } else {
    "Disconnected"
  }
}

# volume
def volume [] {
  pamixer --get-volume-human | tr -d '%'
}

def "audio toggle" [] {
  if (pamixer --get-mute | into bool) {
    pamixer --unmute
  } else {
    pamixer --mute
  }
}

# return audio icon
def "audio icon" [] {
  if (pamixer --get-mute | into bool) {
    '󰖁'
  } else {
    '󰕾'
  }
}

# list audio sinks
def "audio sinks" [] {
  pamixer --list-sinks
  | lines
  | parse '{id} {driver} {status} {name}'
  | str trim
}

# configure audio
def "configure audio" [] {
  pavucontrol
}

# bluetooth commands
def bluetooth [] {
  bluetoothctl devices
  | lines
  | parse "{device} {mac} {name}"
  | select mac name
}

# toggle bluetooth for device
def "bluetooth toggle" [pattern: string] {
  if (bluetooth connected $pattern) {
    bluetooth disconnect $pattern
  } else {
    bluetooth connect $pattern
  }
}

# connect to bluetooth device
def "bluetooth connect" [pattern: string] {
  let mac = (bluetooth | where name =~ $pattern | get mac)
  bluetoothctl power on
  bluetoothctl connect $mac
}

# disconnect to bluetooth device
def "bluetooth disconnect" [pattern: string] {
  let mac = (bluetooth | where name =~ $pattern | get mac)
  bluetoothctl disconnect $mac
  bluetoothctl power off
}

# test whether connected to bluetooth device
def "bluetooth connected" [pattern: string] {
  let tbl = (bluetooth | where name =~ $pattern)
  if ($tbl | length) > 0 {
    let mac = ($tbl | get mac.0)
    (bluetoothctl info $mac
    | rg Connected
    | parse "{rest}: {answer}"
    | get answer.0
    | str trim) == "yes"
  } else {
    false
  }
}

# return bluetooth headphones icon
def "bluetooth headphones icon" [] {
  if (bluetooth connected "beats") {
    '󰋋'
  } else {
    '󰟎'
  }
}

# return bluetooth speaker icon
def "bluetooth speaker icon" [] {
  if (bluetooth connected "Echo") {
    '󰓃'
  } else {
    '󰓄'
  }
}

# set volume
def "set volume" [value: int] {
  if ($value > 0) {
    pamixer --unmute
    pamixer --list-sinks
    | lines
    | parse -r '^(?<sink>\d+).*'
    | get sink
    | each { |sink| pamixer --sink $sink --set-volume $value }
  } else {

  }
}

# brightness functions
def brightness [] {
  let max_path = "/sys/class/backlight/intel_backlight/max_brightness"
  let path = "/sys/class/backlight/intel_backlight/brightness"
  (open $path | lines | get 0 | into int) / (open $max_path | lines | get 0 | into int) * 100 | into int
}

# set brightness
def "set brightness" [value: int] {
  let max_path = "/sys/class/backlight/intel_backlight/max_brightness"
  let path = "/sys/class/backlight/intel_backlight/brightness"
  let v = ($value * (open $max_path | lines | get 0 | into int) / 100 | into int)
  echo $v | into string | save -f $path
}

# clock functions
def clock [] { date now }
def "clock hour" [] { clock | date format '%H'  }
def "clock minute" [] { clock | date format '%M' }
def "clock weekday" [] { clock | date format '%a'}
def "clock day" [] { clock | date format '%d' }
def "clock month" [] { clock | date format '%-m' }
def "clock year" [] { clock | date format '%Y' }
def "clock full" [] {
  let v = (clock | date format '%A, %B %d')
  $"'($v)'"
}

# toggle
def eww-toggle [name: string] {
  let lock = $"/tmp/eww_($name).lock"
  if ($lock | path exists) {
    eww-close $name
  } else {
    eww-open $name
  }
}

# eww open
def eww-open [name: string] {
  eww-close all
  touch $"/tmp/eww_($name).lock"
  eww open $name
}

# eww close
def eww-close [name: string] {
  eww close $name
  rm $"/tmp/eww_($name).lock"
}

# eww close all locked windows
def "eww-close all" [] {
    do -i {
      ls /tmp/eww*
      | get name
      | parse -r '/tmp/eww_(?<widget>.+).lock'
      | get widget
      | each { |w| eww-close $w }
    }
}

# eww update
def eww-update [
  updates: string # format '<key>=<cmd>,...'
  widget?: string # open a widget after updating
] {
  if ($widget != null) { eww-open $widget }
  if $updates != "" {
    let kvs = (
      $updates
      | split column ','
      | transpose col updates
      | get updates
      | each { |update| parse-update $update }
      | flatten
      | each { |x| $"($x.var)=(nu --config ~/.config/eww/eww.nu -c $x.cmd | str trim)" }
      | str join ' '
      | str replace -a '\n' ' ')
    # TODO(danj): weird bug in rendering here
    # echo $"eww update ($kvs)\n" | save /tmp/eww.log --append
    nu -c $"eww update ($kvs)\n"
  }
}

# parse an update element, format is <var> or <var>=<cmd>
# if only <var> is supplied, it is assumed that the command
# to be run is <var> where '-' are replaced with ' '.
def parse-update [update: string] {
  if ($update | str contains '=') {
    $update | split column "=" var cmd | str trim
  } else {
    [
      [var, cmd];
      [($update | str trim), ($update | str replace -a '-' ' ' | str trim)]
    ]
  }
}

# get gpu usage
def "gpu cpu" [] {
  nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits
}

# get gpu memory usage
def "gpu mem" [] {
  let used = (nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | into int)
  let total = (nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | into int)
  $used / $total * 100
}

# powermenu commands
def powermenu [] {}
def "powermenu bspwm" [] { bspc wm -r }
def "powermenu lock" [] { XSECURELOCK_SAVER=saver_xscreensaver xsecurelock }
def "powermenu logout" [] { bspc quit }
def "powermenu reboot" [] { sudo reboot }
def "powermenu shutdown" [] { sudo shutdown -h now }
