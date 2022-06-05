#!/bin/sh

# Distribution of workspaces to monitors
bspc monitor HDMI-1 -d 1 2 3 4 5
bspc monitor DP-3 -d 6 7 8 9 0

# Setup of monitor position, resolution and hertz
xrandr --output DP-3 --mode 1920x1080 --rate 75 --primary --right-of HDMI-1

# Example Wacom Tablet setup
#xsetwacom set 'Wacom Intuos BT S Pen stylus' MapToOutput 1920x1080+1920+0
#xsetwacom set 'Wacom Intuos BT S Pad pad' Button 1 'key +Control_L z'
#xsetwacom set 'Wacom Intuos BT S Pad pad' Button 2 'key +Control_L +Shift_L d'
#xsetwacom set 'Wacom Intuos BT S Pad pad' Button 3 'key +Control_L minus'
#xsetwacom set 'Wacom Intuos BT S Pad pad' Button 8 'key +Control_L +Shift_L equal'

