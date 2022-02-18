#!/bin/sh

#  createTeleporterPodest.sh
#
#  Creates an 5x5 teleporter podest around the given position.
#  The acting component, the command_block has to be set seperatly!
#  (See subscript setCommand)
#
#  Use setCommand at the very end of your script - sometimes the inbuild
#  command fires instantly, your player is teleported to the given location
#  and later setblock orders might no longer be executed!
#
#  Created by Felix Miske on 09.10.18.
#  

X=""
Y=""
Z=""

# Read parameters
# x: = x coordinate (east <-> west)
# y: = height (up <-> down)
# z: = z coordinate (south <-> north)
USAGE="Usage: $0 [-x x coordinate (east <-> west)] [-y height (up <-> down)] [-z z coordinate (south <-> north)]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate missing"; exit 1; fi


# create podest
echo "setblock $(($X - 2)) $Y $(($Z - 2)) quartz_stairs[facing=south,shape=outer_left]"
echo "setblock $(($X - 1)) $Y $(($Z - 2)) quartz_stairs[facing=south]"
echo "setblock $X $Y $(($Z - 2)) quartz_stairs[facing=south]"
echo "setblock $(($X + 1)) $Y $(($Z - 2)) quartz_stairs[facing=south]"
echo "setblock $(($X + 2)) $Y $(($Z - 2)) quartz_stairs[facing=south,shape=outer_right]"
echo "setblock $(($X + 2)) $Y $(($Z - 1)) quartz_stairs[facing=west]"
echo "setblock $(($X + 2)) $Y $Z quartz_stairs[facing=west]"
echo "setblock $(($X + 2)) $Y $(($Z + 1)) quartz_stairs[facing=west]"
echo "setblock $(($X + 2)) $Y $(($Z + 2)) quartz_stairs[facing=west,shape=outer_right]"
echo "setblock $(($X + 1)) $Y $(($Z + 2)) quartz_stairs[facing=north]"
echo "setblock $X $Y $(($Z + 2)) quartz_stairs[facing=north]"
echo "setblock $(($X - 1)) $Y $(($Z + 2)) quartz_stairs[facing=north]"
echo "setblock $(($X - 2)) $Y $(($Z + 2)) quartz_stairs[facing=north,shape=outer_right]"
echo "setblock $(($X - 2)) $Y $(($Z + 1)) quartz_stairs[facing=east]"
echo "setblock $(($X - 2)) $Y $Z quartz_stairs[facing=east]"
echo "setblock $(($X - 2)) $Y $(($Z - 1)) quartz_stairs[facing=east]"

# fill podest
echo "setblock $(($X - 1)) $Y $(($Z - 1)) obsidian"
echo "setblock $X $Y $(($Z - 1)) obsidian"
echo "setblock $(($X + 1)) $Y $(($Z - 1)) obsidian"
echo "setblock $(($X + 1)) $Y $Z obsidian"
echo "setblock $(($X + 1)) $Y $(($Z + 1)) obsidian"
echo "setblock $X $Y $(($Z + 1)) obsidian"
echo "setblock $(($X - 1)) $Y $(($Z + 1)) obsidian"
echo "setblock $(($X - 1)) $Y $Z obsidian"
echo "setblock $X $Y $Z redstone_lamp"
echo "setblock $X $(($Y + 1)) $Z light_weighted_pressure_plate"
echo""
