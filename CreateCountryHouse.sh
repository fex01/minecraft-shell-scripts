#!/bin/sh

# Creates the necassary commands for Minecraft to create a Country
# House at a given position
# * Java (-j)
# * Bedrock (default)
#
#  Created by fex on 01/12/2019.
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
USAGE="Usage: $0 [-x x_coord] [-y y_coord] [-z z_coord]
    [-o (optional) orientation] [-j (optional) set for Java Edition]
    [-u (optional) set for underground placement]
    [-d (optional) to delete the structure]"
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
minLW="-14"
maxLW="14"
minY="0"
maxY="19"
minCW="-1"
maxCW="26"


getOrientX () {
    orientX=""
    case $ORIENTATION in
        north|west) orientX="$(($X+$1))";;
        south|east) orientX="$(($X-$1))";;
        west) orientX="$(($Z-$1))";;
        east) orientX="$(($Z+$1))";;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
    echo "$orientX"
}


getOrientZ () {
    orientZ=""
    case $ORIENTATION in
        north|east) orientZ="$(($Z+$1))";;
        south|west) orientZ="$(($Z-$1))";;
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


createVerticalBeam () {
    createFill $1 0 $2 $1 $3 $2 "$(getBlockValue acacia_log)"
}


createLengthwiseBeam () {
    case $ORIENTATION in
        north|south)
            createFill $1 $2 $3 $1 $2 $(($3+$4)) \
                "$(getBlockValue acacia_log axis z)"
            ;;
        west|east)
            createFill $1 $2 $3 $1 $2 $(($3+$4)) \
                "$(getBlockValue acacia_log axis x)"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}


createCrossBeam () {
    case $ORIENTATION in
        north|south)
            createFill $1 $2 $3 $(($1+$4)) $2 $3 \
                "$(getBlockValue acacia_log axis x)"
            ;;
        west|east)
            createFill $1 $2 $3 $(($1+$4)) $2 $3 \
                "$(getBlockValue acacia_log axis z)"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}

createTorchRing () {
    createBlock $(($1-1)) $2 $3 "$(getBlockValue wall_torch facing west)"
    createBlock $1 $2 $(($3+1)) "$(getBlockValue wall_torch facing south)"
    createBlock $(($1+1)) $2 $3 "$(getBlockValue wall_torch facing east)"
    createBlock $1 $2 $(($3-1)) "$(getBlockValue wall_torch facing north)"
}

shiftStartPosition () {
	# shift start position by 1 block back, necessary to provide space for
    # enclosure
	case $ORIENTATION in
		north) Z=$(($Z+1));;
		south) Z=$(($Z-1));;
		west) X=$(($X+1));;
		east) X=$(($X-1));;
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


createFoundation () {
    printComment "createFoundation"
    createFill -11 0 4 11 0 20 "$(getBlockValue cobblestone hollow)"
    printComment ""
}


createFramework () {
    printComment "createFramework"
    createVerticalBeam -11 4 10
    createVerticalBeam -5 4 10
    createVerticalBeam -1 4 4
    createVerticalBeam 1 4 4
    createVerticalBeam 5 4 10
    createVerticalBeam 11 4 10
    createVerticalBeam -11 8 10
    createVerticalBeam -5 8 14
    createVerticalBeam 5 8 14
    createVerticalBeam 11 8 10
    createVerticalBeam -11 12 15
    createVerticalBeam 11 12 15
    createVerticalBeam -11 16 10
    createVerticalBeam -5 16 14
    createVerticalBeam 5 16 14
    createVerticalBeam 11 16 10
    createVerticalBeam -11 20 10
    createVerticalBeam -5 20 10
    createVerticalBeam -1 20 4
    createVerticalBeam 1 20 4
    createVerticalBeam 5 20 10
    createVerticalBeam 11 20 10
    createLengthwiseBeam -11 5 5 15
    createLengthwiseBeam -5 5 5 15
    createLengthwiseBeam 5 5 5 15
    createLengthwiseBeam 11 5 5 15
    createLengthwiseBeam -11 11 5 15
    createLengthwiseBeam -5 11 5 15
    createLengthwiseBeam 5 11 5 15
    createLengthwiseBeam 11 11 5 15
    createCrossBeam 0 3 4 0
    createCrossBeam -11 5 4 22
    createCrossBeam -11 5 8 22
    createCrossBeam -11 5 12 22
    createCrossBeam -11 5 16 22
    createCrossBeam -11 5 20 22
    createCrossBeam -11 11 4 22
    createCrossBeam -11 11 8 22
    createCrossBeam -11 11 12 22
    createCrossBeam -11 11 16 22
    createCrossBeam -11 11 20 22
    createCrossBeam -11 16 12 22
    printComment ""
}


setFWLights () {
    printComment "setFWLights"

    # first floor
    createBlock 10 3 8 "$(getBlockValue wall_torch facing west)"
    createBlock 10 3 12 "$(getBlockValue wall_torch facing west)"
    createBlock 10 3 16 "$(getBlockValue wall_torch facing west)"
    createBlock 5 3 19 "$(getBlockValue wall_torch facing north)"
    createBlock -1 3 19 "$(getBlockValue wall_torch facing north)"
    createBlock -5 3 19 "$(getBlockValue wall_torch facing north)"
    createBlock -10 3 16 "$(getBlockValue wall_torch facing east)"
    createBlock -10 3 12 "$(getBlockValue wall_torch facing east)"
    createBlock -10 3 8 "$(getBlockValue wall_torch facing east)"
    createBlock -5 3 5 "$(getBlockValue wall_torch facing south)"
    createBlock -1 3 5 "$(getBlockValue wall_torch facing south)"
    createBlock 1 3 5 "$(getBlockValue wall_torch facing south)"
    createTorchRing 5 3 8
    createTorchRing 5 3 16
    createTorchRing -5 3 16
    createTorchRing -5 3 8

    # second floor
    createBlock 10 9 8 "$(getBlockValue wall_torch facing west)"
    createBlock 10 9 12 "$(getBlockValue wall_torch facing west)"
    createBlock 10 9 16 "$(getBlockValue wall_torch facing west)"
    createBlock 5 9 19 "$(getBlockValue wall_torch facing north)"
    createBlock -5 9 19 "$(getBlockValue wall_torch facing north)"
    createBlock -10 9 16 "$(getBlockValue wall_torch facing east)"
    createBlock -10 9 12 "$(getBlockValue wall_torch facing east)"
    createBlock -10 9 8 "$(getBlockValue wall_torch facing east)"
    createBlock -5 9 5 "$(getBlockValue wall_torch facing south)"
    createBlock 5 9 5 "$(getBlockValue wall_torch facing south)"
    createTorchRing 5 9 8
    createTorchRing 5 9 16
    createTorchRing -5 9 16
    createTorchRing -5 9 8

    # third floor
    createBlock 10 15 12 "$(getBlockValue wall_torch facing west)"
    createBlock -10 15 12 "$(getBlockValue wall_torch facing east)"
    createTorchRing 5 14 8
    createTorchRing 5 14 16
    createTorchRing -5 14 16
    createTorchRing -5 14 8

    # outside
    createBlock 5 3 21 "$(getBlockValue wall_torch facing south)"
    createBlock 1 3 21 "$(getBlockValue wall_torch facing south)"
    createBlock -1 3 21 "$(getBlockValue wall_torch facing south)"
    createBlock -5 3 21 "$(getBlockValue wall_torch facing south)"
    createBlock 1 3 3 "$(getBlockValue wall_torch facing north)"
    createBlock -1 3 3 "$(getBlockValue wall_torch facing north)"

    printComment ""
}


createOuterWalls () {
    printComment "createOuterWalls"
    # left wall
    createFill 11 1 5 11 4 7 "$(getBlockValue oak_planks)" 
    createFill 11 1 9 11 4 11 "$(getBlockValue oak_planks)"
    createFill 11 1 13 11 4 15 "$(getBlockValue oak_planks)"
    createFill 11 1 17 11 4 19 "$(getBlockValue oak_planks)"
    createFill 11 6 5 11 10 7 "$(getBlockValue oak_planks)" 
    createFill 11 6 9 11 10 11 "$(getBlockValue oak_planks)"
    createFill 11 6 13 11 10 15 "$(getBlockValue oak_planks)"
    createFill 11 6 17 11 10 19 "$(getBlockValue oak_planks)"

    # back wall
    createFill 10 1 20 6 4 20 "$(getBlockValue oak_planks)" 
    createFill 4 1 20 2 4 20 "$(getBlockValue oak_planks)"
    createFill 0 1 20 0 4 20 "$(getBlockValue oak_planks)"
    createFill -2 1 20 -4 4 20 "$(getBlockValue oak_planks)"
    createFill -6 1 20 -10 4 20 "$(getBlockValue oak_planks)"
    createFill 10 6 20 6 10 20 "$(getBlockValue oak_planks)" 
    createFill 4 6 20 -4 10 20 "$(getBlockValue oak_planks)"
    createFill -6 6 20 -10 10 20 "$(getBlockValue oak_planks)"

    # right wall
    createFill -11 1 19 -11 4 17 "$(getBlockValue oak_planks)"
    createFill -11 1 15 -11 4 13 "$(getBlockValue oak_planks)"
    createFill -11 1 11 -11 4 9 "$(getBlockValue oak_planks)" 
    createFill -11 1 7 -11 4 5 "$(getBlockValue oak_planks)"
    createFill -11 6 19 -11 10 17 "$(getBlockValue oak_planks)"
    createFill -11 6 15 -11 10 13 "$(getBlockValue oak_planks)"
    createFill -11 6 11 -11 10 9 "$(getBlockValue oak_planks)"
    createFill -11 6 7 -11 10 5 "$(getBlockValue oak_planks)"

    # front wall
    createFill -10 1 4 -6 4 4 "$(getBlockValue oak_planks)" 
    createFill -4 1 4 -2 4 4 "$(getBlockValue oak_planks)"
    createBlock 0 4 4 "$(getBlockValue oak_planks)"
    createFill 4 1 4 2 4 4 "$(getBlockValue oak_planks)"
    createFill 10 1 4 6 4 4 "$(getBlockValue oak_planks)"
    createFill -10 6 4 -6 10 4 "$(getBlockValue oak_planks)" 
    createFill -4 6 4 4 10 4 "$(getBlockValue oak_planks)"
    createFill 10 6 4 6 10 4 "$(getBlockValue oak_planks)"

    printComment ""
}


createRoof () {
    printComment "createRoof"
    # left side
    createFill 11 12 5 11 12 11 "$(getBlockValue oak_planks)"
    createFill 11 13 6 11 13 11 "$(getBlockValue oak_planks)"
    createFill 11 14 8 11 14 11 "$(getBlockValue oak_planks)"
    createFill 11 15 10 11 15 11 "$(getBlockValue oak_planks)"
    createFill 11 12 13 11 12 19 "$(getBlockValue oak_planks)"
    createFill 11 13 13 11 13 18 "$(getBlockValue oak_planks)"
    createFill 11 14 13 11 14 16 "$(getBlockValue oak_planks)"
    createFill 11 15 13 11 15 14 "$(getBlockValue oak_planks)"

    # back
    createFill 11 12 20 -11 12 20 "$(getBlockValue oak_planks)"

    # right side
    createFill -11 12 19 -11 12 13 "$(getBlockValue oak_planks)"
    createFill -11 13 18 -11 13 13 "$(getBlockValue oak_planks)"
    createFill -11 14 16 -11 14 13 "$(getBlockValue oak_planks)"
    createFill -11 15 14 -11 15 13 "$(getBlockValue oak_planks)"
    createFill -11 12 11 -11 12 5 "$(getBlockValue oak_planks)"
    createFill -11 13 11 -11 13 6 "$(getBlockValue oak_planks)"
    createFill -11 14 11 -11 14 8 "$(getBlockValue oak_planks)"
    createFill -11 15 11 -11 15 10 "$(getBlockValue oak_planks)"

    # front
    createFill -11 12 4 11 12 4 "$(getBlockValue oak_planks)"

    # shingles
    createFill -12 12 21 12 12 21 "$(getBlockValue oak_slab type top)"
    createFill -12 13 20 12 13 20 "$(getBlockValue oak_slab)"
    createFill -12 13 19 12 13 19 "$(getBlockValue oak_slab type top)"
    createFill -12 14 18 12 14 18 "$(getBlockValue oak_slab)"
    createFill -12 14 17 12 14 17 "$(getBlockValue oak_slab type top)"
    createFill -12 15 16 12 15 16 "$(getBlockValue oak_slab)"
    createFill -12 15 15 12 15 15 "$(getBlockValue oak_slab type top)"
    createFill -12 16 14 12 16 14 "$(getBlockValue oak_slab)"
    createFill -12 16 13 12 16 13 "$(getBlockValue oak_slab type top)"
    createBlock -13 17 12 "$(getBlockValue oak_stairs facing east half top)"
    createFill -12 17 12 -10 17 12 "$(getBlockValue oak_planks)"
    createBlock -9 17 12 "$(getBlockValue oak_stairs facing west)"
    createFill -8 17 12 8 17 12 "$(getBlockValue oak_slab)"
    createBlock 9 17 12 "$(getBlockValue oak_stairs facing east)"
    createFill 10 17 12 12 17 12 "$(getBlockValue oak_planks)"
    createBlock 13 17 12 "$(getBlockValue oak_stairs facing west half top)"
    createFill -12 16 11 12 16 11 "$(getBlockValue oak_slab type top)"
    createFill -12 16 10 12 16 10 "$(getBlockValue oak_slab)"
    createFill -12 15 9 12 15 9 "$(getBlockValue oak_slab type top)"
    createFill -12 15 8 12 15 8 "$(getBlockValue oak_slab)"
    createFill -12 14 7 12 14 7 "$(getBlockValue oak_slab type top)"
    createFill -12 14 6 12 14 6 "$(getBlockValue oak_slab)"
    createFill -12 13 5 12 13 5 "$(getBlockValue oak_slab type top)"
    createFill -12 13 4 12 13 4 "$(getBlockValue oak_slab)"
    createFill -12 12 3 12 12 3 "$(getBlockValue oak_slab type top)"

    # double slabs have to be set after shingles
    createBlock 11 13 5 "$(getBlockValue oak_slab type double)"
    createBlock 11 14 7 "$(getBlockValue oak_slab type double)"
    createBlock 11 15 9 "$(getBlockValue oak_slab type double)"
    createBlock 11 16 11 "$(getBlockValue oak_slab type double)"
    createBlock 11 13 19 "$(getBlockValue oak_slab type double)"
    createBlock 11 14 17 "$(getBlockValue oak_slab type double)"
    createBlock 11 15 15 "$(getBlockValue oak_slab type double)"
    createBlock 11 16 13 "$(getBlockValue oak_slab type double)"
    createBlock -11 13 19 "$(getBlockValue oak_slab type double)"
    createBlock -11 14 17 "$(getBlockValue oak_slab type double)"
    createBlock -11 15 15 "$(getBlockValue oak_slab type double)"
    createBlock -11 16 13 "$(getBlockValue oak_slab type double)"
    createBlock -11 13 5 "$(getBlockValue oak_slab type double)"
    createBlock -11 14 7 "$(getBlockValue oak_slab type double)"
    createBlock -11 15 9 "$(getBlockValue oak_slab type double)"
    createBlock -11 16 11 "$(getBlockValue oak_slab type double)"
    printComment ""
}


createFloors () {
    printComment "createFloors"

    # first floor
    createFill 10 0 5 -10 0 7 "$(getBlockValue birch_planks)"
    createFill 10 0 8 6 0 8 "$(getBlockValue birch_planks)"
    createFill 4 0 8 -4 0 8 "$(getBlockValue birch_planks)"
    createFill -6 0 8 -10 0 8 "$(getBlockValue birch_planks)"
    createFill 10 0 9 -10 0 15 "$(getBlockValue birch_planks)"
    createFill 10 0 16 6 0 16 "$(getBlockValue birch_planks)"
    createFill 4 0 16 -4 0 16 "$(getBlockValue birch_planks)"
    createFill -6 0 16 -10 0 16 "$(getBlockValue birch_planks)"
    createFill 10 0 17 -10 0 19 "$(getBlockValue birch_planks)"

    # second floor
    createFill 10 6 5 -10 6 7 "$(getBlockValue birch_planks)"
    createFill 10 6 8 6 6 8 "$(getBlockValue birch_planks)"
    createFill 4 6 8 -4 6 8 "$(getBlockValue birch_planks)"
    createFill -6 6 8 -10 6 8 "$(getBlockValue birch_planks)"
    createFill 10 6 9 -10 6 15 "$(getBlockValue birch_planks)"
    createFill 10 6 16 6 6 16 "$(getBlockValue birch_planks)"
    createFill 4 6 16 -4 6 16 "$(getBlockValue birch_planks)"
    createFill -6 6 16 -10 6 16 "$(getBlockValue birch_planks)"
    createFill 10 6 17 -10 6 19 "$(getBlockValue birch_planks)"

    # third floor
    createFill 10 12 5 -10 12 7 "$(getBlockValue birch_planks)"
    createFill 10 12 8 6 12 8 "$(getBlockValue birch_planks)"
    createFill 4 12 8 -4 12 8 "$(getBlockValue birch_planks)"
    createFill -6 12 8 -10 12 8 "$(getBlockValue birch_planks)"
    createFill 10 12 9 -10 12 15 "$(getBlockValue birch_planks)"
    createFill 10 12 16 6 12 16 "$(getBlockValue birch_planks)"
    createFill 4 12 16 -4 12 16 "$(getBlockValue birch_planks)"
    createFill -6 12 16 -10 12 16 "$(getBlockValue birch_planks)"
    createFill 10 12 17 -10 12 19 "$(getBlockValue birch_planks)"

    printComment ""
}


createIndoorWalls () {
    printComment "createIndoorWalls"

    # first floor
    createFill -6 1 11 -7 5 11 "$(getBlockValue oak_planks)"
    createFill -8 1 9 -8 5 11 "$(getBlockValue oak_planks)"
    createFill -8 1 8 -6 4 8 "$(getBlockValue oak_planks)"
    createFill -5 1 11 -5 4 15 "$(getBlockValue oak_planks)"
    createFill -4 1 16 1 4 16 "$(getBlockValue oak_planks)"
    createFill 2 1 9 2 4 16 "$(getBlockValue oak_planks)"
    createFill 2 5 13 2 5 15 "$(getBlockValue oak_planks)"
    createFill 2 5 9 2 5 11 "$(getBlockValue oak_planks)"
    createFill 3 1 8 4 4 8 "$(getBlockValue oak_planks)"
    createFill 5 1 5 5 4 7 "$(getBlockValue oak_planks)"
    createFill 0 1 17 0 5 19 "$(getBlockValue oak_planks)"

    printComment ""
}


setWallLights () {
    printComment "setWallLights"

    # first floor
    createBlock 1 3 18 "$(getBlockValue wall_torch facing east)"
    createBlock 3 3 14 "$(getBlockValue wall_torch facing east)"
    createBlock 3 3 11 "$(getBlockValue wall_torch facing east)"
    createBlock 1 3 14 "$(getBlockValue wall_torch facing west)"
    createBlock 1 3 11 "$(getBlockValue wall_torch facing west)"
    createBlock 2 3 8 "$(getBlockValue wall_torch facing north)"
    createBlock 4 3 6 "$(getBlockValue wall_torch facing west)"
    createBlock -2 3 15 "$(getBlockValue wall_torch facing north)"
    createBlock -4 3 15 "$(getBlockValue wall_torch facing north)"
    createBlock -4 3 11 "$(getBlockValue wall_torch facing east)"

    printComment ""
}


createFrontPorch () {
    printComment "createFrontPorch"
    createBlock -1 0 0 "$(getBlockValue stone_brick_slab)"
    createBlock 0 0 0 "$(getBlockValue stone_brick_slab)"
    createBlock 1 0 0 "$(getBlockValue stone_brick_slab)"
    createFill 4 0 1 -4 0 3 "$(getBlockValue stone_bricks)"
    createBlock -4 1 3 "$(getBlockValue oak_fence)"
    createBlock -4 1 2 "$(getBlockValue oak_fence)"
    createBlock -4 1 1 "$(getBlockValue oak_fence)"
    createBlock -3 1 1 "$(getBlockValue oak_fence)"
    createBlock -2 1 1 "$(getBlockValue oak_fence)"
    createBlock 4 1 3 "$(getBlockValue oak_fence)"
    createBlock 4 1 2 "$(getBlockValue oak_fence)"
    createBlock 4 1 1 "$(getBlockValue oak_fence)"
    createBlock 3 1 1 "$(getBlockValue oak_fence)"
    createBlock 2 1 1 "$(getBlockValue oak_fence)"
    createBlock -4 2 1 "$(getBlockValue torch)"
    createBlock 4 2 1 "$(getBlockValue torch)"
    printComment ""
}


createBackPorch () {
    printComment "createBackPorch"
    createBlock -2 0 25 "$(getBlockValue dark_oak_slab)"
    createBlock -1 0 25 "$(getBlockValue dark_oak_slab)"
    createBlock 0 0 25 "$(getBlockValue dark_oak_slab)"
    createBlock 1 0 25 "$(getBlockValue dark_oak_slab)"
    createBlock 2 0 25 "$(getBlockValue dark_oak_slab)"
    createFill 4 0 24 -4 0 21 "$(getBlockValue dark_oak_planks)"
    createBlock -4 1 21 "$(getBlockValue oak_fence)"
    createBlock -4 1 22 "$(getBlockValue oak_fence)"
    createBlock -4 1 23 "$(getBlockValue oak_fence)"
    createBlock -4 1 24 "$(getBlockValue oak_fence)"
    createBlock -3 1 24 "$(getBlockValue oak_fence)"
    createBlock 4 1 21 "$(getBlockValue oak_fence)"
    createBlock 4 1 22 "$(getBlockValue oak_fence)"
    createBlock 4 1 23 "$(getBlockValue oak_fence)"
    createBlock 4 1 24 "$(getBlockValue oak_fence)"
    createBlock 3 1 24 "$(getBlockValue oak_fence)"
    printComment ""
}


setWindowsAndDoors () {
    printComment "setWindowsAndDoors"
    # left
    createFill 11 2 6 11 3 6 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill 11 2 10 11 3 10 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill 11 2 14 11 3 14 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill 11 2 18 11 3 18 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill 11 8 6 11 9 6 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill 11 8 10 11 9 10 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill 11 8 14 11 9 14 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill 11 8 18 11 9 18 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"

    # back
    createFill 9 2 20 7 3 20 "$(getBlockValue glass_pane \
        $(getFacing east) true $(getFacing west) true)"
    createBlock 3 1 20 "$(getBlockValue oak_door facing north hinge right)"
    createBlock 3 2 20 "$(getBlockValue oak_door facing north half upper hinge \
        right)"
    createBlock -3 1 20 "$(getBlockValue oak_door facing north)"
    createBlock -3 2 20 "$(getBlockValue oak_door facing north half upper)"
    createFill -7 2 20 -9 3 20 "$(getBlockValue glass_pane $(getFacing east) \
        true $(getFacing west) true)"
    createFill 9 8 20 7 9 20 "$(getBlockValue glass_pane $(getFacing east) \
        true $(getFacing west) true)"
    createFill 3 8 20 1 9 20 "$(getBlockValue glass_pane $(getFacing east) \
        true $(getFacing west) true)"
    createFill -1 8 20 -3 9 20 "$(getBlockValue glass_pane $(getFacing east) \
        true $(getFacing west) true)"
    createFill -7 8 20 -9 9 20 "$(getBlockValue glass_pane $(getFacing east) \
        true $(getFacing west) true)"

    # right
    createFill -11 2 6 -11 3 6 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill -11 2 10 -11 3 10 "$(getBlockValue glass_pane \
        $(getFacing north) true $(getFacing south) true)"
    createFill -11 2 14 -11 3 14 "$(getBlockValue glass_pane \
        $(getFacing north) true $(getFacing south) true)"
    createFill -11 2 18 -11 3 18 "$(getBlockValue glass_pane \
        $(getFacing north) true $(getFacing south) true)"
    createFill -11 8 6 -11 9 6 "$(getBlockValue glass_pane $(getFacing north) \
        true $(getFacing south) true)"
    createFill -11 8 10 -11 9 10 "$(getBlockValue glass_pane \
        $(getFacing north) true $(getFacing south) true)"
    createFill -11 8 14 -11 9 14 "$(getBlockValue glass_pane \
        $(getFacing north) true $(getFacing south) true)"
    createFill -11 8 18 -11 9 18 "$(getBlockValue glass_pane \
        $(getFacing north) true $(getFacing south) true)"

    # front
    createFill 3 2 4 3 3 4 "$(getBlockValue glass_pane $(getFacing east) true \
        $(getFacing west) true)"
    createBlock 0 1 4 "$(getBlockValue oak_door facing south)"
    createBlock 0 2 4 "$(getBlockValue oak_door facing south half upper)"
    createFill -3 2 4 -3 3 4 "$(getBlockValue glass_pane $(getFacing east) \
        true $(getFacing west) true)"
    createFill -7 2 4 -9 3 4 "$(getBlockValue glass_pane $(getFacing east) \
        true $(getFacing west) true)"
    createFill 9 8 4 7 9 4 "$(getBlockValue glass_pane $(getFacing east) true \
        $(getFacing west) true)"
    createFill 2 8 4 -2 9 4 "$(getBlockValue glass_pane $(getFacing east) true \
        $(getFacing west) true)"
    createFill -7 8 4 -9 9 4 "$(getBlockValue glass_pane $(getFacing east) \
        true $(getFacing west) true)"

    # indoor
    createBlock 2 1 12 "$(getBlockValue oak_door facing east)"
    createBlock 2 2 12 "$(getBlockValue oak_door facing east half upper)"
    createBlock 2 1 13 "$(getBlockValue oak_door facing east hinge right)"
    createBlock 2 2 13 "$(getBlockValue oak_door facing east half upper hinge \
        right)"
    createBlock -3 1 16 "$(getBlockValue oak_door facing south)"
    createBlock -3 2 16 "$(getBlockValue oak_door facing south half upper)"

    printComment ""
}


createStairs () {
    printComment "createStairs"
    createBlock -5 3 9 "$(getBlockValue air)"
    createFill -8 5 9 -8 5 10 "$(getBlockValue air)"
    createFill -7 6 9 -10 6 10 "$(getBlockValue air)"
    createFill -9 6 11 -10 6 11 "$(getBlockValue air)"
    createFill -6 5 9 -6 5 10 "$(getBlockValue wall_torch facing west)"
    createFill -6 6 9 -6 6 10 "$(getBlockValue birch_stairs facing east half \
        top)"
    createBlock -4 1 8 "$(getBlockValue birch_stairs facing west shape \
        outer_left)"
    createFill -4 1 9 -4 1 10 "$(getBlockValue birch_stairs facing west)"
    createBlock -4 1 11 "$(getBlockValue birch_stairs facing west shape \
        outer_right)"
    createFill -5 1 9 -5 1 10 "$(getBlockValue oak_planks)"
    createFill -5 2 9 -5 2 10 "$(getBlockValue birch_stairs facing west)"
    createFill -6 1 9 -6 1 10 "$(getBlockValue oak_planks)"
    createFill -6 2 9 -6 2 10 "$(getBlockValue birch_planks)"
    createFill -7 1 9 -7 2 10 "$(getBlockValue oak_planks)"
    createFill -7 3 9 -7 3 10 "$(getBlockValue birch_stairs facing west)"
    createFill -8 4 9 -8 4 10 "$(getBlockValue birch_stairs facing west)"
    createBlock -9 4 9 "$(getBlockValue birch_stairs facing south shape \
        inner_left half top)"
    createBlock -10 4 9 "$(getBlockValue birch_stairs facing south shape \
        inner_right half top)"
    createBlock -9 4 10 "$(getBlockValue birch_stairs facing north shape \
        inner_right half top)"
    createBlock -10 4 10 "$(getBlockValue birch_stairs facing north shape \
        inner_left half top)"
    createFill -9 5 11 -10 5 11 "$(getBlockValue birch_stairs facing south)"
    createFill -9 6 12 -10 6 12 "$(getBlockValue birch_stairs facing south)"
    createFill -10 7 13 -10 15 13 "$(getBlockValue ladder facing east)"
    createBlock -10 12 13 "$(getBlockValue birch_trapdoor facing east half top)"
    createBlock -10 16 13 "$(getBlockValue oak_trapdoor facing east half top)"
    printComment ""
}


createChimney () {
    printComment "createChimney"
    createFill 6 0 5 10 0 9 "$(getBlockValue bricks)"
    createFill 6 6 5 10 6 9 "$(getBlockValue bricks)"
    createFill 6 12 5 10 12 9 "$(getBlockValue bricks)"
    createFill 7 1 6 9 18 7 "$(getBlockValue bricks)"
    createFill 7 8 8 9 18 8 "$(getBlockValue bricks)"
    createFill 8 6 7 8 18 7 "$(getBlockValue air)"
    createBlock 8 1 7 "$(getBlockValue air)"
    createBlock 7 1 8 "$(getBlockValue bricks)"
    createBlock 9 1 8 "$(getBlockValue bricks)"
    createFill 7 2 8 9 2 8 "$(getBlockValue brick_slab)"
    createFill 7 5 8 9 5 8 "$(getBlockValue polished_andesite)"
    createBlock 7 7 8 "$(getBlockValue bricks)"
    createBlock 9 7 8 "$(getBlockValue bricks)"
    createBlock 8 0 7 "$(getBlockValue netherrack)"
    createBlock 8 6 7 "$(getBlockValue netherrack)"
    createBlock 8 1 7 "$(getBlockValue fire)"
    createBlock 8 7 7 "$(getBlockValue fire)"
    printComment ""
}


setHouseholdItems () {
    printComment "setHouseholdItems"
    createBlock 0 1 5 "$(getBlockValue birch_pressure_plate)"
    createBlock 1 1 12 "$(getBlockValue birch_pressure_plate)"
    createBlock 1 1 13 "$(getBlockValue birch_pressure_plate)"
    createBlock 3 1 12 "$(getBlockValue birch_pressure_plate)"
    createBlock 3 1 13 "$(getBlockValue birch_pressure_plate)"
    createBlock 3 1 19 "$(getBlockValue birch_pressure_plate)"
    createBlock -3 1 19 "$(getBlockValue birch_pressure_plate)"
    createBlock -3 1 17 "$(getBlockValue birch_pressure_plate)"
    createBlock -3 1 15 "$(getBlockValue birch_pressure_plate)"
    createBlock -6 1 19 "$(getBlockValue brewing_stand)"
    createBlock -7 1 19 "$(getBlockValue furnace facing north)"
    createBlock -8 1 19 "$(getBlockValue crafting_table)"
    createBlock -9 1 19 "$(getBlockValue furnace facing north)"
    createBlock -10 1 19 "$(getBlockValue crafting_table)"
    createBlock -10 1 18 "$(getBlockValue cauldron level 3)"
    createBlock -10 1 17 "$(getBlockValue crafting_table)"
    createBlock -6 1 14 "$(getBlockValue chest facing west)"
    createBlock -6 1 15 "$(getBlockValue chest facing west)"
    printComment ""
}


printComment "Create Country House at position $X/$Y/$Z facing $ORIENTATION"
printComment ""
prepareArea

if [ "$DELETE" ]; then exit 0; fi

createFoundation
createFramework
setFWLights
createOuterWalls
createRoof
createFloors
createIndoorWalls
setWallLights
createFrontPorch
createBackPorch
setWindowsAndDoors
createStairs
createChimney
setHouseholdItems
printComment "Finished"
printComment ""
