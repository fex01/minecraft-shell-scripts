#!/bin/sh

#  setCommand.sh
#
#  Sets an command_block at the given location with the given command.
#  Destroys already exiting blocks at the same position - this enables to
#  override already exiting command_blocks.
#
#  Be aware that the command_block is sometimes instantly activated - which
#  might cause problems if you, for example, use a teleport command and your
#  player is teleported before the end of your script.
#
#  Created by Felix Miske on 09.10.18.
#  

X=""
Y=""
Z=""
COMMAND=""

# Read parameters
# x: = x coordinate (east <-> west)
# y: = height (up <-> down)
# z: = z coordinate (south <-> north)
# c: = command for the command_block
USAGE="Usage: $0 [-x x coordinate (east <-> west)] [-y height (up <-> down)] [-z z coordinate (south <-> north)] [-c command for the command_block]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:c:" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        c) COMMAND="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate missing"; exit 1; fi
if [ "$COMMAND" = "" ]; then echo "command missing"; exit 1; fi


# create podest
echo "setblock $X $Y $Z air"
echo "setblock $X $Y $Z command_block{Command:\"$COMMAND\"} destroy"
