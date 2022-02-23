#!/bin/sh

# Fill a space with a block type taking orientation and offset into account
#
# Created by fex on 23.02.2022
#

X=""
Y=""
Z=""
X1OFFSET=""
Y1OFFSET=""
Z1OFFSET=""
X2OFFSET=""
Y2OFFSET=""
Z2OFFSET=""
BLOCK=""
ORIENTATION="south"

# Read parameters
# x: = x2 coordinate (east(+) <-> west(-))
# y: = y2 coordinate (up(+) <-> down(-))
# z: = z2 coordinate (south(+) <-> north(-))
# r: = x1 offset
# s: = y1 offset
# t: = z1 offset
# u: = x2 offset
# v: = y2 offset
# w: = z2 offset
# b: = block
# <o>: = (optional) orientation (south, west, north or east), default is south
USAGE="Usage: $0 [-x x coordinate] [-y y coordinate] [-z z coordinate]
    [-r x1 offset] [-v y1 offset] [-t z1 offset]
    [-u x2 offset] [-v y2 offset] [-w z2 offset] [-b block]
    [-o (optional) orientation (south, west, north or east), default is south]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:r:s:t:u:v:w:b:o:" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        r) X1OFFSET="$OPTARG";;
        s) Y1OFFSET="$OPTARG";;
        t) Z1OFFSET="$OPTARG";;
        u) X2OFFSET="$OPTARG";;
        v) Y2OFFSET="$OPTARG";;
        w) Z2OFFSET="$OPTARG";;
        b) BLOCK="$OPTARG";;
        o) ORIENTATION="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate (-x) is missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate (-y) is missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate (-z) is missing"; exit 1; fi
if [ "$X1OFFSET" = "" ]; then echo "x1 offset (-r) is missing"; exit 1; fi
if [ "$Y1OFFSET" = "" ]; then echo "y1 offset (-s) is missing"; exit 1; fi
if [ "$Z1OFFSET" = "" ]; then echo "z1 offset (-t) is missing"; exit 1; fi
if [ "$X2OFFSET" = "" ]; then echo "x2 offset (-u) is missing"; exit 1; fi
if [ "$Y2OFFSET" = "" ]; then echo "y2 offset (-v) is missing"; exit 1; fi
if [ "$Z2OFFSET" = "" ]; then echo "z2 offset (-w) is missing"; exit 1; fi
if [ "$BLOCK" = "" ]; then echo "block (-b) is missing"; exit 1; fi
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
        echo "fill $(getOrientX $X1OFFSET) $(($Y + $Y1OFFSET)) $(getOrientZ $Z1OFFSET)"\
            "$(getOrientX $X2OFFSET) $(($Y + $Y2OFFSET)) $(getOrientZ $Z2OFFSET) $BLOCK"
        ;;
    west|east)
        echo "fill $(getOrientX $Z1OFFSET) $(($Y + $Y1OFFSET)) $(getOrientZ $X1OFFSET)"\
            "$(getOrientX $Z2OFFSET) $(($Y + $Y2OFFSET)) $(getOrientZ $X2OFFSET) $BLOCK"
        ;;
    *) "Orientation must be south, west, north or east."; exit 1
esac
