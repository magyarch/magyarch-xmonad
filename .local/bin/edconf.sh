#!/bin/bash



# Dmenu script for editing some of my more frequently edited config files.


declare options=("alias
bash
profile
vifm
sxhkd
xmonad
xmobarrc
xprofile
quit")

choice=$(echo -e "${options[@]}" | dmenu -i -c -g 1 -l 10 -nb '#000000' -sb '#947cc3' -fn 'JetBrains Mono Medium-12' -p 'Edit config files: ')

case "$choice" in
	quit)
		echo "Program terminated." && exit 1
	;;
	alias)
		choice="$HOME/.config/aliasrc"
	;;
	bash)
		choice="$HOME/.bashrc"
	;;
	xmonad)
		choice="$HOME/.xmonad/xmonad.hs"
	;;
	profile)
		choice="$HOME/.profile"
	;;
	vifm)
		choice="$HOME/.config/vifm/vifmrc"
	;;
	xmobarrc)
		choice="$HOME/.xmobarrc"
	;;
	sxhkd)
		choice="$HOME/.config/sxhkd/sxhkdrc"
	;;
	xprofile)
		choice="$HOME/.xprofile"
	;;
	*)
		exit 1
	;;
esac
subl -c "$choice"
