#!/bin/bash

# mp3reclaimer
# retrieves mp3 files stored on ipods and renames them based on their id3 tags

# created 2015-06-26 agrinberg
# modified 2016-10-22 agrinberg

# set variables
myname=`basename $0`
ipodVolumePath=
ipodMusicPath="iPod_Control/Music"
outputDir=`pwd`
verbose=0

# declare functions
error() # error handler
{
	echo "$myname: $1" >1&2
}

check_dir() # checks if argument is a valid path
{
	if [ ! -d "$1" ]; then
		error "invalid path $1"
		exit 1
	fi
}

get_id3_tag() # gets id3 tag on supplied file
{
	id3v2 --list "$1" | LANG=C sed -e 's/TPE1/TP1/g' -e 's/TIT2/TT2/g' | grep -e "^$2" | awk 'BEGIN { FS=": " } ; { print $2 }'
}

showhelp() # print help text
{
	cat <<EOF
mp3reclaimer by andrey
usage: $myname [-o DIR] [-v] PATH
retrieves mp3 files from ipod volume PATH and renames them based on id3 tags

  -h, --help			 show this help text and exit
  -o, --outputdir <DIR>		 directory to copy mp3 files to; defaults to cwd
  -v, --verbose			 verbose output while copying files

example:
  $myname -v -o ~/mp3 /Volumes/iPod
EOF
}

# parse options and arguments
while [ $# -gt 0 ]; do
	case $1 in
		-o|--outputdir)
			outputDir="$2"
			shift 2
			;;
		-h|-\?|--help)
			showhelp
			exit 0
			;;
		-v|--verbose)
			verbose=1
			shift
			;;
		-*|--*)
			error "invalid option $1"
			exit 1
			;;
		*)
			ipodVolumePath="$1"
			shift
			;;
	esac
done

# perform sanity check
check_dir "$ipodVolumePath"
check_dir "$ipodVolumePath/$ipodMusicPath"
check_dir "$outputDir"

# execute
for f in "$ipodVolumePath/$ipodMusicPath"/**/*.mp3; do

	dupecounter=1
	artist=`get_id3_tag "$f" "TP1"`
	if [ "X$artist" = "X" ]; then
		artist="Unknown Artist"
	fi

	artist=`echo "$artist" | LANG=C sed 's/:/;/g'`
	artist=`echo "$artist" | LANG=C sed 's/\//:/g'`

	title=`get_id3_tag "$f" "TT2"`
	if [ "X$title" = "X" ]; then
		title="Unknown Title"
	fi

	title=`echo "$title" | LANG=C sed 's/:/;/g'`
	title=`echo "$title" | LANG=C sed 's/\//:/g'`

	newfilename="$artist - $title"

	while [ -f "$outputDir/$newfilename.mp3" ]; do
		let dupecounter=dupecounter+1
		newfilename="$artist - $title ($dupecounter)"
	done

	if [ $verbose = 1 ]; then
		cp -v "$f" "$outputDir/$newfilename.mp3"
	else
		cp "$f" "$outputDir/$newfilename.mp3"
	fi
done
