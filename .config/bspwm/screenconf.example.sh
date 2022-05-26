#!/bin/sh

bspc monitor HDMI-1 -d 1 2 3 4 5
bspc monitor DP-3 -d 6 7 8 9 0

xrandr --output DP-3 --mode 1920x1080 --rate 75 --primary --right-of HDMI-1

