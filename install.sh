#!/bin/bash

### Global variables
prog="Current Progression = "
full_install_mode=0
#

### Input Guards

usage(){
	echo "no args mean light installation"
	echo "arg --full-install mean the full installation"
	echo "warning it does take 651mb to make the full install"
	exit
}
if [ -z $1 ]
then
	:
elif [ $1 == "--full-install" ]
then
	echo "full install mode choosed, i warn, i don't check space left and it's 651mb"
	full_install_mode=1
elif [ $1 == "-help" ] || [ $1 == "--help" ] || [ $1 == "-h" ]
then
	usage
fi

#

### Dependencies Check

dependencies_check(){
	is_missing=false
	dependencies=('ffmpeg' 'jp2a' 'convert' )
	for dp in "${dependencies[@]}"
	do
		fn_exists "$dp"
		[ $? -eq 1 ] && is_missing=true
	done
	[ $is_missing = true ] && return 1
	return 0
}

fn_exists()
{
	type $1 &> /dev/null
	if [ $? -eq 1 ]
	then
		echo "missing $1" >&2
		return 1
	fi
	return 0
}
#

### Functions

installing(){
	all_dir=$(ls -l ./assets/ | grep "^d" | grep -Eo "[^ ]+$" | tr -s '\n' ' ')
	all_dir=($all_dir)
	numberofdir=${#all_dir[@]}
	let -i i=0;
	echo "Converting gif to ascii"
	for dir in "${all_dir[@]}"
	do
		progression
		convert_png "$1" &
		wait $!
		convert_jpg "$1" & 
		wait $!
		jpg_to_ascii "$dir"
		cleaner "$dir"
	done
	echo
	echo "I guess it's okay from now"
}
progression(){
	echo -n "$prog""$i"/"$numberofdir"""
	i=$[$i+1]
	sleep 0.5
	echo -ne "\033[0K\r"
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



#

### Main Function
 
 
dependencies_check
if [ $? -eq 1 ]
then
	echo "missing dependencies... stopping"

fi
if [ $full_install_mode -eq 1 ]
then
installing
fi
echo "Seems to have encountered no error, you're ready to launch the script now"

#
