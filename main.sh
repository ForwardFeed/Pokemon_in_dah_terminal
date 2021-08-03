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

# if not previously installed we need to install all the animation. should takes up to a second.
# $1 name of the dir the pokemon is in
installing(){
	dir=$1
	convert_png & #give it a subshell because it will cd because of some odd reason i couldn't manage to prevent
	wait $!
	convert_jpg 
	jpg_to_ascii "$1"
	cleaner "$1"

}


convert_png(){
	cd ./assets/"$dir"/
	$(ffmpeg -hide_banner -loglevel panic -i "./"$dir".gif" -vsync 0 animation%05d.png) >/dev/null
}

convert_jpg(){
	all_png=$(ls ./assets/"$dir" | grep "anim" |tr -s '\n' ' ')
	all_png=($all_png)
	for png in ${all_png[@]}
	do
		sub_convert_jpg "$png"
	done
}

# $1 => PNG to convert
sub_convert_jpg(){
	convert "./assets/"$dir"/"$1""  ./assets/"$dir"/$(echo "$1" | sed --expression='s/.png/.jpg/g')
	rm "./assets"/"$dir"/"$1"
}

# $1 => directory
jpg_to_ascii(){
	all_jpg=$(ls ./assets/$1 | grep -E "animation[0-9]{5}.jpg" |tr -s '\n' ' ')
	all_jpg=($all_jpg)
	for jpg in "${all_jpg[@]}"
	do
		jp2a "./assets/"$1"/"$jpg"" --size=60x30 --color --background=light > ./assets/"$1"/$(echo "$jpg" | sed --expression='s/.jpg//g')
		rm "./assets/"$1"/"$jpg""
	done
}

# $1 => directory
cleaner(){
	rm "./assets/"$1"/"$1".gif"
}



# function to print the pokemon to the screen
load_ascii_mon(){
	sleep_time=$(echo "scale=4; 1/$frequency" | bc) 
	all_frames=$(ls "$assets""$pokemon" | tr -s '\n' ' ')
	all_frames=($all_frames)
	if [ ${#all_frames[@]} -eq 0 ]
	then
		echo "The directory seems empty or maybe it doesn't exist"
		echo "did you typed it right"
		exit
	elif [ ${#all_frames[@]} -eq 1 ]
	then
		installing "$pokemon"
		all_frames=$(ls "$assets""$pokemon" | tr -s '\n' ' ')
		all_frames=($all_frames)
	fi
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
