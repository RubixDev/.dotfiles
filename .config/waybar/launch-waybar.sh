#!/bin/sh
trap "killall waybar" EXIT
while true; do
    waybar &
    inotifywait -e create,modify "${XDG_CONFIG_HOME:-$HOME/.config}/waybar/"*
    killall waybar
done
