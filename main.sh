#!/bin/bash

usage(){
	echo "the first args in the pokemon you want to be shown (is mandatory)"
	echo "example ./main.sh Emolga"
	echo "the second arg is here if you want to modify the framerate (is optional)"
	echo "example ./main.sh tododile 10 #means 10 frame per second"
	exit
}


###Global Variables
	assets="./assets/"
	frequency=24 #default 24 frames per second
	[ -z $1 ] && usage
	pokemon=${1^}
	[ ! -z $2 ] && frequency=$2
	
#

### Functions

# function to print the pokemon to the screen
load_ascii_mon(){
	sleep_time=$(echo "scale=4; 1/$frequency" | bc) 
	all_frames=$(ls "$assets""$pokemon" | tr -s '\n' ' ')
	all_frames=($all_frames)
	declare -a frames
	declare -i i=0
	#load all frames first
	for frame in "${all_frames[@]}"
	do
		frames[i]=$(cat "$assets""$pokemon"/"$frame")
		i=$((i+1));
	done
	tput civis #makes the pointer invisible
	#now we can print to the screen
	for frame in "${frames[@]}"
	do
		tput cup 1 0
		echo "$frame"
		sleep "$sleep_time"
		tput cup 1 0
	done
}

# function who will manage the draw to the screen
# $1 name of pokemon to redraw
redraw() {
	cols=$( tput cols )
	rows=$( tput lines )
	clear
	if [ $cols -lt 60 ] || [ $rows -lt 30 ]
	then
		echo "need 60x30 screen to print cool pokemon :c"
	else
	load_ascii_mon $1 $2
	fi
}

# function to make the cursor revisible once the user exit
clean_exit() {
	clear
	tput cnorm
	exit
}



#

### Main Function

trap clean_exit INT TERM #cleaner exit imo
trap redraw WINCH #will redraw if the terminal change size
redraw

#add redraw in this loop if you want the "gif" to be looping too
while true; do
	:
done

#
