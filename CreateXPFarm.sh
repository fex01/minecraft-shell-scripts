#!/bin/sh

# Work in Progress - not functional
# Creates the necassary commands for Minecraft to create the Avo's
# Journey (https://www.youtube.com/channel/UCeprnLp3l8oZPAig8XjVLnA)
# XP Farm
# Currently only for Bedrock
#
#  Created by fex on 17/02/2022.
#

X=""
Y=""
Z=""
ORIENTATION="south"
EDITION="bedrock"
ENCLOSE="FALSE"
DELETE="FALSE"
BLOCK="air"

# Read parameters
# x: = x coordinate (east(+) <-> west(-))
# y: = y coordinate (up(+) <-> down(-))
# z: = z coordinate (south(+) <-> north(-))
# <o>: = (optional) orientation (south, west, north or east), default is south
# <j>: = (optional) set flag to generate output for Java
# <u>: = (optional) set flag if you place the structure underground, will 
#   create an enclosure
# <d>: = (optional) set flag to delete the structure
USAGE="Usage: $0 [-x x_coord] [-y y_coord] [-z z_coord] [-o (optional) orientation] [-j (optional) set for Java Edition] [-u (optional) set for underground placement] [-d (optional) to delete the structure]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:o:jud" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        o) ORIENTATION="$OPTARG";;
        j) EDITION="java";;
        u) ENCLOSE="TRUE"; BLOCK="stone";;
        d) DELETE="TRUE";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate missing"; exit 1; fi
if [ "$ORIENTATION" != "south" ] && 
    [ "$ORIENTATION" != "west" ] && 
    [ "$ORIENTATION" != "north" ] && 
    [ "$ORIENTATION" != "east" ]
then
    echo "Orientation must be unset, south, west, north or east."
    exit 1
fi


printComment () {
    echo "say $1"
}


# outer edges
# LW: Lengthwise, CW: Crosswise
minLW="-8"
maxLW="8"
minY="-4"
maxY="4"
minCW="0"
maxCW="18"


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


getFacing () {
    # wrapper for ./Subfunctions/getFacing.sh to improve readability
    if [ -n "$2" ]; then
        ./Subfunctions/getFacing.sh -o "$ORIENTATION" -e "$EDITION" -b "$1" \
            -f "$2"
    else
        ./Subfunctions/getFacing.sh -o "$ORIENTATION" -e "$EDITION" -f "$1"
    fi   
}


getBlockValue () {
    # wrapper for ./Subfunctions/getBlockValue.sh to improve readability
    block="$1"
    shift

    if [ -n "$1" ]; then
        ./Subfunctions/getBlockValue.sh -o "$ORIENTATION" -e "$EDITION" \
            -b "$block" -a "$@"
    else
        ./Subfunctions/getBlockValue.sh -o "$ORIENTATION" -e "$EDITION" \
            -b "$block"
    fi
}


createBlock () {
    # wrapper for ./Subfunctions/createBlock.sh to improve readability
    ./Subfunctions/createBlock.sh -x "$X" -y "$Y" -z "$Z" -o "$ORIENTATION" \
        -u "$1" -v "$2" -w "$3" -b "$4"
}


createFill () {
    # wrapper for ./Subfunctions/createFill.sh to improve readability
    ./Subfunctions/createFill.sh -x "$X" -y "$Y" -z "$Z" -o "$ORIENTATION" \
        -r "$1" -s "$2" -t "$3" -u "$4" -v "$5" -w "$6" -b "$7"
}

shiftStartPosition () {
	# shift start position by 1 block back, necessary to provide space for 
    # enclosure
	case $ORIENTATION in
		north) Z=$(($Z + 1));;
		south) Z=$(($Z - 1));;
		west) X=$(($X + 1));;
		east) X=$(($X - 1));;
        *) "Orientation must be south, west, north or east."; exit 1
    esac	
}


prepareArea () {
	if [ $ENCLOSE ]; then
		shiftStartPosition
		./Subfunctions/createEnclosure.sh -u $(getOrientX $minLW) \
            -v $(($Y+$minY)) -w $(getOrientZ $minCW) -x $(getOrientX $maxLW) \
            -y $(($Y+$maxY)) -z $(getOrientZ $maxCW) -g $Y\
            -b "$(getBlockValue smooth_quartz)" \
            -s "$(getBlockValue smooth_quartz)" \
            -r "$(getBlockValue glowstone)" -o "$ORIENTATION" -l
        if [ $DELETE ]; then
            # change outer edeges to include enclosure
            minLW="$(($minLW-1))"
            maxLW="$(($maxLW+1))"
            minY="$(($minY-1))"
            maxY=$(($maxY+1))
            minCW="$(($minCW-1))"
            maxCW="$(($maxCW+1))"
        fi
	fi
    printComment "Clear Area"
    createFill $minLW $minY $minCW $maxLW $maxY $maxCW "$BLOCK"
    printComment ""
}


printComment "Create XP Farm at position $X/$Y/$Z facing $ORIENTATION"
printComment ""
prepareArea

if [ "$DELETE" = "TRUE" ]; then exit 0; fi


printComment "Finished"
printComment ""
