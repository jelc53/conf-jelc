# load .Xresources for consistent dpi
xrdb -merge ~/.Xresources
# get rid of ugly X cursor
xsetroot -cursor_name left_ptr
# load keymaps
xmodmap ~/.Xmodmap
# start wm
exec dbus-launch --exit-with-x11 bspwm
