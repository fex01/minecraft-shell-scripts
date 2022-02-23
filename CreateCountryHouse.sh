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
ORIENTATION="north"
EDITION="bedrock"
ENCLOSE=""
DELETE=""
BLOCK="air"

# Read parameters
# x: = x coordinate (east(+) <-> west(-))
# y: = y coordinate (up(+) <-> down(-))
# z: = z coordinate (south(+) <-> north(-))
# <o>: = orientation (south, west, north or east), default is south
# <d>: = set flag to delete the structure, value: replacement block type 
#   (default air)
# <j>: = (optional) set flag to generate output for Java
# <u>: = (optional) set flag if you place the structure underground, will 
#   create an enclosure
USAGE="Usage: $0 [-x x_coord] [-y y_coord] [-z z_coord]
    [-o (optional) orientation] [-j (optional) set for Java Edition]
    [-u (optional) set for underground placement]
    [-d (optional) to delete the structure]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:o:jud:" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        o) ORIENTATION="$OPTARG";;
        j) EDITION="java";;
        u) ENCLOSE="TRUE";;
        d) DELETE="TRUE"; BLOCK="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate missing"; exit 1; fi
if [ "$ORIENTATION" != "south" ] &&\
    [ "$ORIENTATION" != "west" ] &&\
    [ "$ORIENTATION" != "north" ] &&\
    [ "$ORIENTATION" != "east" ]
then
    echo "Orientation must be south, west, north or east."
    exit 1
fi


printComment () {
    echo "say $1"
}


# outer edges
minLW="-14"
maxLW="14"
minY="0"
maxY="19"
minCW="-1"
maxCW="26"


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


createVerticalBeam () {
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r $1 -s 0 \
        -t $2 -u $1 -v $3 -w $2 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b acacia_log)"
}


createLengthwiseBeam () {
    case $ORIENTATION in
        north|south)
            ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION \
                -r $1 -s $2 -t $3 -u $1 -v $2 -w $(($3+$4)) \
                -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
                -e $EDITION -b acacia_log -a axis z)"
            ;;
        west|east)
            ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION \
                -r $1 -s $2 -t $3 -u $1 -v $2 -w $(($3+$4)) \
                -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
                -e $EDITION -b acacia_log -a axis x)"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}


createCrossBeam () {
    case $ORIENTATION in
        north|south)
            ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION \
                -r $1 -s $2 -t $3 -u $(($1+$4)) -v $2 -w $3 \
                -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
                -e $EDITION -b acacia_log -a axis x)"
            ;;
        west|east)
            ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION \
                -r $1 -s $2 -t $3 -u $(($1+$4)) -v $2 -w $3 \
                -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
                -e $EDITION -b acacia_log -a axis z)"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}

createTorchRing () {
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z \
        -u $(($1 - 1)) -v $2 -w $3 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u $1 \
        -v $2 -w $(($3 + 1)) -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b wall_torch -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z \
        -u $(($1 + 1)) -v $2 -w $3 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u $1 \
        -v $2 -w $(($3 - 1)) -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b wall_torch -a facing north)"
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
            -v $(($Y + $minY)) -w $(getOrientZ $minCW) -x $(getOrientX $maxLW) \
            -y $(($Y + $maxY)) -z $(getOrientZ $maxCW) -g $Y\
            -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION -e $EDITION \
            -b smooth_quartz)"\
            -s "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION -e $EDITION \
            -b smooth_quartz)"\
            -r "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION -e $EDITION \
            -b glowstone)" -o "$ORIENTATION" -l
        if [ $DELETE ]; then
            # change outer edeges to include enclosure
            minLW="$(($minLW - 1))"
            maxLW="$(($maxLW + 1))"
            minY="$(($minY - 1))"
            maxY=$(($maxY + 1))
            minCW="$(($minCW - 1))"
            maxCW="$(($maxCW + 1))"
        fi
	fi
    printComment "Clear Area"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r $minLW \
        -s $minY -t $minCW -u $maxLW -v $maxY -w $maxCW -b "$BLOCK"
    printComment ""
}


createFoundation () {
    printComment "createFoundation"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 0 \
        -t 4 -u 11 -v 0 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b cobblestone -a hollow)"
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
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 10 -v 3 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION -e $EDITION \
        -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 10 -v 3 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 10 -v 3 -w 16 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 5 -v 3 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -1 -v 3 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -5 -v 3 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 3 -w 16 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 3 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 3 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -5 -v 3 -w 5 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -1 -v 3 -w 5 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 3 -w 5 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    createTorchRing 5 3 8
    createTorchRing 5 3 16
    createTorchRing -5 3 16
    createTorchRing -5 3 8

    # second floor
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 10 -v 9 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 10 -v 9 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 10 -v 9 -w 16 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 5 -v 9 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -5 -v 9 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 9 -w 16 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 9 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 9 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -5 -v 9 -w 5 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 5 -v 9 -w 5 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    createTorchRing 5 9 8
    createTorchRing 5 9 16
    createTorchRing -5 9 16
    createTorchRing -5 9 8

    # third floor
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 10 -v 15 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 15 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    createTorchRing 5 14 8
    createTorchRing 5 14 16
    createTorchRing -5 14 16
    createTorchRing -5 14 8

    # outside
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 5 -v 3 -w 21 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 3 -w 21 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -1 -v 3 -w 21 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -5 -v 3 -w 21 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 3 -w 3 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -1 -v 3 -w 3 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"

    printComment ""
}


createOuterWalls () {
    printComment "createOuterWalls"
    # left wall
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 1 \
        -t 5 -u 11 -v 4 -w 7 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)" 
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 1 \
        -t 9 -u 11 -v 4 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 1 \
        -t 13 -u 11 -v 4 -w 15 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 1 \
        -t 17 -u 11 -v 4 -w 19 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 6 \
        -t 5 -u 11 -v 10 -w 7 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)" 
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 6 \
        -t 9 -u 11 -v 10 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 6 \
        -t 13 -u 11 -v 10 -w 15 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 6 \
        -t 17 -u 11 -v 10 -w 19 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    # back wall
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 1 \
        -t 20 -u 6 -v 4 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)" 
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 1 \
        -t 20 -u 2 -v 4 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 0 -s 1 \
        -t 20 -u 0 -v 4 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -2 -s 1 \
        -t 20 -u -4 -v 4 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 1 \
        -t 20 -u -10 -v 4 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 6 \
        -t 20 -u 6 -v 10 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)" 
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 6 \
        -t 20 -u -4 -v 10 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 6 \
        -t 20 -u -10 -v 10 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    # right wall
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 1 \
        -t 19 -u -11 -v 4 -w 17 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 1 \
        -t 15 -u -11 -v 4 -w 13 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 1 \
        -t 11 -u -11 -v 4 -w 9 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)" 
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 1 \
        -t 7 -u -11 -v 4 -w 5 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 6 \
        -t 19 -u -11 -v 10 -w 17 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 6 \
        -t 15 -u -11 -v 10 -w 13 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 6 \
        -t 11 -u -11 -v 10 -w 9 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 6 \
        -t 7 -u -11 -v 10 -w 5 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    # front wall
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -10 -s 1 \
        -t 4 -u -6 -v 4 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)" 
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -4 -s 1 \
        -t 4 -u -2 -v 4 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 0 -v 4 -w 4 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 1 \
        -t 4 -u 2 -v 4 -w 4 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 1 \
        -t 4 -u 6 -v 4 -w 4 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -10 -s 6 \
        -t 4 -u -6 -v 10 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)" 
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -4 -s 6 \
        -t 4 -u 4 -v 10 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 6 \
        -t 4 -u 6 -v 10 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    printComment ""
}


createRoof () {
    printComment "createRoof"
    # left side
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 12 \
        -t 5 -u 11 -v 12 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 13 \
        -t 6 -u 11 -v 13 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 14 \
        -t 8 -u 11 -v 14 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 15 \
        -t 10 -u 11 -v 15 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 12 \
        -t 13 -u 11 -v 12 -w 19 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 13 \
        -t 13 -u 11 -v 13 -w 18 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 14 \
        -t 13 -u 11 -v 14 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 15 \
        -t 13 -u 11 -v 15 -w 14 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    # back
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 12 \
        -t 20 -u -11 -v 12 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    # right side
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 12 \
        -t 19 -u -11 -v 12 -w 13 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 13 \
        -t 18 -u -11 -v 13 -w 13 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 14 \
        -t 16 -u -11 -v 14 -w 13 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 15 \
        -t 14 -u -11 -v 15 -w 13 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 12 \
        -t 11 -u -11 -v 12 -w 5 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 13 \
        -t 11 -u -11 -v 13 -w 6 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 14 \
        -t 11 -u -11 -v 14 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 15 \
        -t 11 -u -11 -v 15 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    # front
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 12 \
        -t 4 -u 11 -v 12 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    # shingles
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 12 \
        -t 21 -u 12 -v 12 -w 21 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 13 \
        -t 20 -u 12 -v 13 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 13 \
        -t 19 -u 12 -v 13 -w 19 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 14 \
        -t 18 -u 12 -v 14 -w 18 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 14 \
        -t 17 -u 12 -v 14 -w 17 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 15 \
        -t 16 -u 12 -v 15 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 15 \
        -t 15 -u 12 -v 15 -w 15 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 16 \
        -t 14 -u 12 -v 16 -w 14 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 16 \
        -t 13 -u 12 -v 16 -w 13 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -13 -v 17 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_stairs -a facing east half top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 17 \
        -t 12 -u -10 -v 17 -w 12 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -9 -v 17 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_stairs -a facing west)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -8 -s 17 \
        -t 12 -u 8 -v 17 -w 12 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 9 -v 17 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_stairs -a facing east)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 17 \
        -t 12 -u 12 -v 17 -w 12 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 13 -v 17 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_stairs -a facing west half top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 16 \
        -t 11 -u 12 -v 16 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 16 \
        -t 10 -u 12 -v 16 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 15 \
        -t 9 -u 12 -v 15 -w 9 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 15 \
        -t 8 -u 12 -v 15 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 14 \
        -t 7 -u 12 -v 14 -w 7 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 14 \
        -t 6 -u 12 -v 14 -w 6 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 13 \
        -t 5 -u 12 -v 13 -w 5 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 13 \
        -t 4 -u 12 -v 13 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -12 -s 12 \
        -t 3 -u 12 -v 12 -w 3 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_slab -a type top)"

    # double slabs have to be set after shingles
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 11 -v 13 -w 5 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 11 -v 14 -w 7 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 11 -v 15 -w 9 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 11 -v 16 -w 11 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 11 -v 13 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 11 -v 14 -w 17 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 11 -v 15 -w 15 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 11 -v 16 -w 13 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -11 -v 13 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -11 -v 14 -w 17 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -11 -v 15 -w 15 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -11 -v 16 -w 13 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -11 -v 13 -w 5 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -11 -v 14 -w 7 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -11 -v 15 -w 9 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -11 -v 16 -w 11 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_slab -a type double)"
    printComment ""
}


createFloors () {
    printComment "createFloors"

    # first floor
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 0 \
        -t 5 -u -10 -v 0 -w 7 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 0 \
        -t 8 -u 6 -v 0 -w 8 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 0 \
        -t 8 -u -4 -v 0 -w 8 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 0 \
        -t 8 -u -10 -v 0 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 0 \
        -t 9 -u -10 -v 0 -w 15 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 0 \
        -t 16 -u 6 -v 0 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 0 \
        -t 16 -u -4 -v 0 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 0 \
        -t 16 -u -10 -v 0 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 0 \
        -t 17 -u -10 -v 0 -w 19 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"

    # second floor
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 6 \
        -t 5 -u -10 -v 6 -w 7 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 6 \
        -t 8 -u 6 -v 6 -w 8 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 6 \
        -t 8 -u -4 -v 6 -w 8 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 6 \
        -t 8 -u -10 -v 6 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 6 \
        -t 9 -u -10 -v 6 -w 15 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 6 \
        -t 16 -u 6 -v 6 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 6 \
        -t 16 -u -4 -v 6 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 6 \
        -t 16 -u -10 -v 6 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 6 \
        -t 17 -u -10 -v 6 -w 19 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"

    # third floor
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 12 \
        -t 5 -u -10 -v 12 -w 7 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 12 \
        -t 8 -u 6 -v 12 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 12 \
        -t 8 -u -4 -v 12 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 12 \
        -t 8 -u -10 -v 12 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 12 \
        -t 9 -u -10 -v 12 -w 15 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 12 \
        -t 16 -u 6 -v 12 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 12 \
        -t 16 -u -4 -v 12 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 12 \
        -t 16 -u -10 -v 12 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 10 -s 12 \
        -t 17 -u -10 -v 12 -w 19 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"

    printComment ""
}


createIndoorWalls () {
    printComment "createIndoorWalls"

    # first floor
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 1 \
        -t 11 -u -7 -v 5 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -8 -s 1 \
        -t 9 -u -8 -v 5 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -8 -s 1 \
        -t 8 -u -6 -v 4 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -5 -s 1 \
        -t 11 -u -5 -v 4 -w 15 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -4 -s 1 \
        -t 16 -u 1 -v 4 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 2 -s 1 \
        -t 9 -u 2 -v 4 -w 16 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 2 -s 5 \
        -t 13 -u 2 -v 5 -w 15 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 2 -s 5 \
        -t 9 -u 2 -v 5 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 3 -s 1 \
        -t 8 -u 4 -v 4 -w 8 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 5 -s 1 \
        -t 5 -u 5 -v 4 -w 7 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 0 -s 1 \
        -t 17 -u 0 -v 5 -w 19 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"

    printComment ""
}


setWallLights () {
    printComment "setWallLights"

    # first floor
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 3 -w 18 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 3 -w 14 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 3 -w 11 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 3 -w 14 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 3 -w 11 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 2 -v 3 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 3 -w 6 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -2 -v 3 -w 15 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 3 -w 15 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 3 -w 11 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b wall_torch -a facing east)"

    printComment ""
}


createFrontPorch () {
    printComment "createFrontPorch"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -1 -v 0 -w 0 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b stone_brick_slab)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 0 -v 0 -w 0 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b stone_brick_slab)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 0 -w 0 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b stone_brick_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 0 \
        -t 1 -u -4 -v 0 -w 3 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b stone_bricks)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 -w 3 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 -w 2 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 -w 1 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 1 -w 1 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -2 -v 1 -w 1 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 1 -w 3 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 1 -w 2 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 1 -w 1 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 1 -w 1 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 2 -v 1 -w 1 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 2 -w 1 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b torch)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 2 -w 1 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b torch)"
    printComment ""
}


createBackPorch () {
    printComment "createBackPorch"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -2 -v 0 -w 25 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b dark_oak_slab)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -1 -v 0 -w 25 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b dark_oak_slab)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 0 -v 0 -w 25 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b dark_oak_slab)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 0 -w 25 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b dark_oak_slab)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 2 -v 0 -w 25 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b dark_oak_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 4 -s 0 \
        -t 24 -u -4 -v 0 -w 21 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b dark_oak_planks)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 -w 21 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 -w 22 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 -w 23 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 -w 24 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 1 -w 24 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 1 -w 21 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 1 -w 22 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 1 -w 23 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 4 -v 1 -w 24 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 1 -w 24 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_fence)"
    printComment ""
}


setWindowsAndDoors () {
    printComment "setWindowsAndDoors"
    # left
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 2 \
        -t 6 -u 11 -v 3 -w 6 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 2 \
        -t 10 -u 11 -v 3 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 2 \
        -t 14 -u 11 -v 3 -w 14 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 2 \
        -t 18 -u 11 -v 3 -w 18 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 8 \
        -t 6 -u 11 -v 9 -w 6 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 8 \
        -t 10 -u 11 -v 9 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 8 \
        -t 14 -u 11 -v 9 -w 14 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 11 -s 8 \
        -t 18 -u 11 -v 9 -w 18 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"

    # back
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 9 -s 2 \
        -t 20 -u 7 -v 3 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 1 -w 20 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing north hinge right)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 2 -w 20 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing north half upper hinge \
        right)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 1 -w 20 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 2 -w 20 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing north half upper)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -7 -s 2 \
        -t 20 -u -9 -v 3 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 9 -s 8 \
        -t 20 -u 7 -v 9 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 3 -s 8 \
        -t 20 -u 1 -v 9 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -1 -s 8 \
        -t 20 -u -3 -v 9 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -7 -s 8 \
        -t 20 -u -9 -v 9 -w 20 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"

    # right
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 2 \
        -t 6 -u -11 -v 3 -w 6 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 2 \
        -t 10 -u -11 -v 3 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 2 \
        -t 14 -u -11 -v 3 -w 14 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 2 \
        -t 18 -u -11 -v 3 -w 18 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 8 \
        -t 6 -u -11 -v 9 -w 6 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 8 \
        -t 10 -u -11 -v 9 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 8 \
        -t 14 -u -11 -v 9 -w 14 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -11 -s 8 \
        -t 18 -u -11 -v 9 -w 18 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f north -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f south -o $ORIENTATION -e $EDITION) \
        true)"

    # front
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 3 -s 2 \
        -t 4 -u 3 -v 3 -w 4 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 0 -v 1 -w 4 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 0 -v 2 -w 4 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing south half upper)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -3 -s 2 \
        -t 4 -u -3 -v 3 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -7 -s 2 \
        -t 4 -u -9 -v 3 -w 4 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 9 -s 8 \
        -t 4 -u 7 -v 9 -w 4 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 2 -s 8 \
        -t 4 -u -2 -v 9 -w 4 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -7 -s 8 \
        -t 4 -u -9 -v 9 -w 4 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b glass_pane \
        -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) \
        true \
        $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) \
        true)"

    # indoor
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 2 -v 1 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 2 -v 2 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing east half upper)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 2 -v 1 -w 13 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing east hinge right)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 2 -v 2 -w 13 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing east half upper hinge right)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 1 -w 16 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing south)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 2 -w 16 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_door -a facing south half upper)"

    printComment ""
}


createStairs () {
    printComment "createStairs"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -5 -v 3 -w 9 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b air)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -8 -s 5 \
        -t 9 -u -8 -v 5 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b air)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -7 -s 6 \
        -t 9 -u -10 -v 6 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b air)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -9 -s 6 \
        -t 11 -u -10 -v 6 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b air)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 5 \
        -t 9 -u -6 -v 5 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b wall_torch -a facing west)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 6 \
        -t 9 -u -6 -v 6 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_stairs -a facing east half top)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 \
        -w 8 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_stairs -a facing west shape outer_left)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -4 -s 1 \
        -t 9 -u -4 -v 1 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_stairs -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -4 -v 1 \
        -w 11 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_stairs -a facing west shape outer_right)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -5 -s 1 \
        -t 9 -u -5 -v 1 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -5 -s 2 \
        -t 9 -u -5 -v 2 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_stairs -a facing west)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 1 \
        -t 9 -u -6 -v 1 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -6 -s 2 \
        -t 9 -u -6 -v 2 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -7 -s 1 \
        -t 9 -u -7 -v 2 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b oak_planks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -7 -s 3 \
        -t 9 -u -7 -v 3 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_stairs -a facing west)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -8 -s 4 \
        -t 9 -u -8 -v 4 -w 10 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_stairs -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -9 -v 4 -w 9 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_stairs -a facing south shape inner_left half top)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 4 -w 9 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_stairs -a facing south shape inner_right half \
        top)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -9 -v 4 -w 10 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_stairs -a facing north shape inner_right half \
        top)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 4 -w 10 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_stairs -a facing north shape inner_left half top)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -9 -s 5 \
        -t 11 -u -10 -v 5 -w 11 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_stairs -a facing south)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -9 -s 6 \
        -t 12 -u -10 -v 6 -w 12 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b birch_stairs -a facing south)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r -10 -s 7 \
        -t 13 -u -10 -v 15 -w 13 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b ladder -a facing east)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 \
        -v 12 -w 13 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_trapdoor -a facing east half top)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 \
        -v 16 -w 13 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b oak_trapdoor -a facing east half top)"
    printComment ""
}


createChimney () {
    printComment "createChimney"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 6 -s 0 \
        -t 5 -u 10 -v 0 -w 9 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b bricks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 6 -s 6 \
        -t 5 -u 10 -v 6 -w 9 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b bricks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 6 -s 12 \
        -t 5 -u 10 -v 12 -w 9 -b "$(./Subfunctions/getBlockValue.sh \
        -o $ORIENTATION -e $EDITION -b bricks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 7 -s 1 \
        -t 6 -u 9 -v 18 -w 7 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b bricks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 7 -s 8 \
        -t 8 -u 9 -v 18 -w 8 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b bricks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 8 -s 6 \
        -t 7 -u 8 -v 18 -w 7 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b air)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 8 -v 1 -w 7 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b air)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 7 -v 1 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b bricks)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 9 -v 1 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b bricks)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 7 -s 2 \
        -t 8 -u 9 -v 2 -w 8 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b brick_slab)"
    ./Subfunctions/createFill.sh -x $X -y $Y -z $Z -o $ORIENTATION -r 7 -s 5 \
        -t 8 -u 9 -v 5 -w 8 -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b polished_andesite)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 7 -v 7 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b bricks)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 9 -v 7 -w 8 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b bricks)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 8 -v 0 -w 7 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b netherrack)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 8 -v 6 -w 7 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b netherrack)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 8 -v 1 -w 7 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b fire)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 8 -v 7 -w 7 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b fire)"
    printComment ""
}


setHouseholdItems () {
    printComment "setHouseholdItems"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 0 -v 1 -w 5 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 1 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 1 -v 1 -w 13 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 1 -w 12 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 1 -w 13 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u 3 -v 1 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 1 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 1 -w 17 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -3 -v 1 -w 15 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b birch_pressure_plate)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -6 -v 1 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b brewing_stand)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -7 -v 1 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b furnace -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -8 -v 1 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b crafting_table)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -9 -v 1 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b furnace -a facing north)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 1 -w 19 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b crafting_table)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 1 -w 18 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b cauldron -a level 3)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -10 -v 1 -w 17 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b crafting_table)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -6 -v 1 -w 14 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b chest -a facing west)"
    ./Subfunctions/createBlock.sh -o $ORIENTATION -x $X -y $Y -z $Z -u -6 -v 1 -w 15 \
        -b "$(./Subfunctions/getBlockValue.sh -o $ORIENTATION \
        -e $EDITION -b chest -a facing west)"
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
