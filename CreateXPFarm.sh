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
        u) ENCLOSE="TRUE";;
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
maxLW="11"
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
    printComment "Clear Area"
    if [ "$DELETE" = "TRUE" ]; then
        if [ "$ENCLOSE" = "TRUE" ]; then
        # change outer edeges to include enclosure
            minLW="$(($minLW-1))"
            maxLW="$(($maxLW+1))"
            minY="$(($minY-1))"
            maxY=$(($maxY+1))
            minCW="$(($minCW-1))"
            maxCW="$(($maxCW+1))"
            createFill $minLW $minY $minCW $maxLW $maxY $maxCW "stone"
        else
            if [ $minY -lt 0 ]; then
                createFill $minLW $minY $minCW $maxLW -1 $maxCW "stone"
            fi
            createFill $minLW 0 $minCW $maxLW $maxY $maxCW "air"
        fi
        printComment ""
        exit 0
    else
        if [ "$ENCLOSE" = "TRUE" ]; then
            shiftStartPosition
            ./Subfunctions/createEnclosure.sh -u $(getOrientX $minLW) \
                -v $(($Y+$minY)) -w $(getOrientZ $minCW) -x $(getOrientX $maxLW) \
                -y $(($Y+$maxY)) -z $(getOrientZ $maxCW) -g $Y\
                -b "$(getBlockValue smooth_quartz)" \
                -s "$(getBlockValue smooth_quartz)" \
                -r "$(getBlockValue glowstone)" -o "$ORIENTATION" -l
            createFill $minLW 0 $minCW $maxLW $maxY $maxCW "air"
        else
            createFill $minLW $minY $minCW $maxLW $maxY $maxCW "air"
        fi
        printComment ""
    fi
}


printComment "Create XP Farm at position $X/$Y/$Z facing $ORIENTATION"
printComment ""
prepareArea

createFill -4 -1 -1 -3 -1 -3 air
createFill -4 -2 -2 -3 -2 -3 air
createFill -4 -3 -3 -3 -3 -3 air
createFill -4 -3 -4 -3 -1 -4 chest facing west
createFill -2 -3 -4 -2 -1 -4 hopper facing west
createFill -1 -1 -4 5 -1 -4 hopper facing west
createFill -4 0 -5 -2 0 -6 stone
createBlock -2 0 -4 stone
createFill -4 1 -4 -2 1 -4 stone
createBlock -4 1 -6 stone
createFill -1 0 -4 5 0 -4 furnace facing south
createFill -1 0 -3 5 0 -3 lever attached north
createFill -1 1 -4 5 1 -4 hopper facing down
createFill -1 0 -5 5 0 -6 hopper facing south
createFill 6 0 -5 8 0 -6 stone
createFill 8 1 -5 8 1 -4 stone
createFill 6 1 -4 7 1 -4 stone
createBlock 8 0 -7 stone
createBlock 5 2 -4 stone
createFill -4 1 -5 4 1 -5 powered_rail e/w
createFill 5 1 -5 6 1 -5 rail e/w
createBlock 7 1 -5 rail w/n
createBlock 7 1 -6 rail s/w
createFill -1 1 -6 6 1 -6 rail e/w
createFill -3 1 -6 -2 1 -6 powered_rail e/w
createBlock -5 0 -5 powered_rail e+/w-
createFill -4 2 -4 -2 2 -4 powered_rail e/w
createFill -1 2 -4 7 2 -4 rail e/w
createBlock 8 2 -4 rail w/n
createBlock 8 2 -5 rail n/s
createBlock 8 2 -6 powered_rail n-/s+
createBlock 8 1 -7 powered_rail n-/s+
createBlock 8 0 -8 powered_rail n-/s+
createBlock -4 0 -4 lever attached north activated
createBlock -5 2 -3 lever attached north activated
createBlock -4 1 -7 lever attached south activated
createBlock -6 0 -5 rail e/n
createBlock -6 -2 -6 redstone_block
createBlock -6 -1 -6 powered_rail n-/s+
createFill -6 -1 -7 -6 -1 -10 air
createBlock -6 -2 -7 powered_rail n-/s+
createFill -6 -2 -8 -6 -2 -9 powered_rail n/s
createBlock -6 -2 -10 dectector_rail n+/s-
createBlock -6 -1 -11 hopper facing south
createBlock -6 -2 -12 comparator facing south
createBlock -7 -2 -10 hopper facing down
createBlock -7 -2 -11 comparator facing south
createBlock -6 -1 -13 redstone_torch attached down
createBlock -7 -2 -12 redstone_dust connecting e/s
createBlock -7 -2 -9 air
createBlock -6 0 -13 stone
createFill -6 1 -10 -6 1 -12 stone
createBlock -6 1 -9 sticky_piston facing down
createBlock -6 0 -9 stone
createFill -6 2 -10 -6 2 -12 redstone_dust connecting n/s
createBlock -6 1 -13 redstone_dust connecting n/s+
fillHoper -7 -2 -10 46 stone
createBlock -5 -1 -11 hopper facing west
createFill -4 0 -11 -5 0 -11 chest facing south
createBlock -3 0 -11 hopper facing west
createFill -3 1 -11 -4 1 -11 chest facing south
createBlock -2 1 -11 hopper facing west
createFill -2 2 -11 -3 1 -11 chest facing south

createBlock 8 -2 -9 redstone_block
createBlock 8 -1 -9 powered_rail n-/s+
createFill 8 -1 -10 8 -1 -13 air
createBlock 8 -2 -10 powered_rail n-/s+
createFill 8 -2 -11 8 -2 -12 powered_rail n/s
createBlock 8 -2 -13 dectector_rail n+/s-
createBlock 8 -1 -14 hopper facing south
createBlock 8 -2 -15 comparator facing south
createBlock 9 -2 -13 hopper facing down
createBlock 9 -2 -14 comparator facing south
createBlock 8 -1 -16 redstone_torch attached down
createBlock 9 -2 -15 redstone_dust connecting w/s
createBlock 9 -2 -12 air
createBlock 8 0 -16 stone
createFill 8 1 -13 8 1 -15 stone
createBlock 8 1 -12 sticky_piston facing down
createBlock 8 0 -12 stone
createFill 8 2 -13 8 2 -15 redstone_dust connecting n/s
createBlock 8 1 -16 redstone_dust connecting n/s+
fillHoper 9 -2 -13 23 stone
createBlock 8 -1 -14 hopper facing east
createFill 7 0 -14 8 0 -14 chest facing south
createBlock 6 0 -14 hopper facing east
createFill 6 1 -14 7 1 -14 chest facing south


printComment "Finished"
printComment ""
