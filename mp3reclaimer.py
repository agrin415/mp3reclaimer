#!/usr/bin/env python

# mp3reclaimer - python version
# retrieves mp3 files stored on ipods and renames them based on id3 tags

# created 2016-10-21 agrinberg
# modified 2016-10-22 agrinberg

import argparse
import glob
import os
import sys
from mutagen.id3 import ID3
from shutil import copyfile

myname = os.path.basename(os.path.normpath(sys.argv[0]))
ipodMusicPath = "iPod_Control/Music"

def error(msg):
	print >>sys.stderr, myname + ": " + msg

def parseArgs():
	parser = argparse.ArgumentParser(
		description="copy mp3 files from iPod and human-readably rename them"
	)

	parser.add_argument(
		"-o",
		"--outputdir",
		default = os.getcwd(),
		help = "specify output directory"
	)

	parser.add_argument(
		"-v",
		"--verbose",
		action="store_true",
		help = "print filenames as they are copied"
	)

	parser.add_argument(
		"path",
		help = "specify iPod volume path"
	)

	return parser.parse_args()

def checkDir(dir):
	if not os.path.isdir(dir):
		error("invalid directory: " + dir)
		sys.exit(1)

def getName(file):
	tags = ID3(file)

	try:
		artist = tags['TPE1'].text[0]
	except KeyError:
		artist = "Unknown Artist"

	try:
		title = tags['TIT2'].text[0]
	except KeyError:
		title = "Unknown Title"

	return artist + " - " + title

def main():
	args = parseArgs()
	outputDir = args.outputdir
	ipodVolumePath = args.path
	verbose = args.verbose

	checkDir(outputDir)
	checkDir(ipodVolumePath)
	checkDir(ipodVolumePath + "/" + ipodMusicPath)

	inputDir = ipodVolumePath + "/" + ipodMusicPath + "/**/*.mp3"

	for file in glob.iglob(inputDir):
		dupeCounter = 1
		reclaimedName = getName(file)	
		reclaimedPath = outputDir + "/" + reclaimedName
		dst = reclaimedPath + ".mp3"

		while os.path.isfile(dst):
			dupeCounter = dupeCounter + 1 
			dst = reclaimedPath + " (" + str(dupeCounter) + ").mp3"

		copyfile(file, dst)
		if verbose:
			print "'" + file + "' -> '" + dst + "'"

main()
