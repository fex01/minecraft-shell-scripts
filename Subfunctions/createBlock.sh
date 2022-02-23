#!/bin/sh

# Place a block taking orientation and offset into account
#
#  Created by fex on 23.02.2022
#

X=""
Y=""
Z=""
XOFFSET=""
YOFFSET=""
ZOFFSET=""
BLOCK=""
ORIENTATION="south"

# Read parameters
# x: = x coordinate (east(+) <-> west(-))
# y: = y coordinate (up(+) <-> down(-))
# z: = z coordinate (south(+) <-> north(-))
# u: = x offset
# v: = y offset
# w: = z offset
# b: = block
# <o>: = (optional) orientation (south, west, north or east), default is south
USAGE="Usage: $0 [-x x_coord] [-y y_coord] [-z z_coord]
    [-u x offset] [-v y offset] [-w z offset] [-b block]
    [-o (optional) orientation (south, west, north or east), default is south]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:u:v:w:b:o:" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        u) XOFFSET="$OPTARG";;
        v) YOFFSET="$OPTARG";;
        w) ZOFFSET="$OPTARG";;
        b) BLOCK="$OPTARG";;
        o) ORIENTATION="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate is missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate is missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate is missing"; exit 1; fi
if [ "$XOFFSET" = "" ]; then echo "x offset (-u) is missing"; exit 1; fi
if [ "$YOFFSET" = "" ]; then echo "y offset (-v) is  missing"; exit 1; fi
if [ "$ZOFFSET" = "" ]; then echo "z offset (-w) is  missing"; exit 1; fi
if [ "$ORIENTATION" != "south" ] &&\
    [ "$ORIENTATION" != "west" ] &&\
    [ "$ORIENTATION" != "north" ] &&\
    [ "$ORIENTATION" != "east" ]
then
    echo "Orientation must be south, west, north or east."
    exit 1
fi


getOrientX () {
    orientX=""
    case $ORIENTATION in
        north|west) orientX="$(($X + $1))";;
        south|east) orientX="$(($X - $1))";;
        west) orientX="$(($Z - $1))";;
        east) orientX="$(($Z + $1))";;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
    echo "$orientX"
}


getOrientZ () {
    orientZ=""
    case $ORIENTATION in
        north|east) orientZ="$(($Z + $1))";;
        south|west) orientZ="$(($Z - $1))";;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
    echo "$orientZ"
}


case $ORIENTATION in
    north|south) 
        echo "setblock $(getOrientX $XOFFSET) $(($Y + $YOFFSET)) $(getOrientZ $ZOFFSET) $BLOCK"
        ;;
    west|east)
        echo "setblock $(getOrientX $ZOFFSET) $(($Y + $YOFFSET)) $(getOrientZ $XOFFSET) $BLOCK"
        ;;
    *) "Orientation must be south, west, north or east."; exit 1
esac
