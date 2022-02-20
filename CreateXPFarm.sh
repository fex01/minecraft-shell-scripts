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
BLOCK=""

# Read parameters
# x: = x coordinate (east(+) <-> west(-))
# y: = y coordinate (up(+) <-> down(-))
# z: = z coordinate (south(+) <-> north(-))
# <o>: = (optional) orientation (south, west, north or east), default is south
# <j>: = (optional) set flag to generate output for Java
# <u>: = (optional) set flag if you place the structure underground, will create an enclosure
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
        d) DELETE="TRUE"; BLOCK="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X" = "" ]; then echo "x coordinate missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "y coordinate missing"; exit 1; fi
if [ "$Z" = "" ]; then echo "z coordinate missing"; exit 1; fi
if [ "$ORIENTATION" != "south" ] && [ "$ORIENTATION" != "west" ] && [ "$ORIENTATION" != "north" ] && [ "$ORIENTATION" != "east" ]
then
    echo "Orientation must be south, west, north or east."
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


getBlockModifier () {
    modifier=""
    block="$1"
    shift

    if [ "$1" = "facing" ]; then
        modifier="$(./Subfunctions/getFacing.sh -b $block -f $2 -o $ORIENTATION -e $EDITION)"
        if [ "$EDITION" = "java" ]; then 
            modifier="facing=$modifier"
            if [ -n "$3" ]; then modifier="$modifier,"; fi
        fi
        shift 2
    fi

    if [ "$EDITION" = "java" ]; then
        until [ -z "$1" ]; do
            modifier="$modifier$1=$2"
            if [ -n "$3" ]; then modifier="$modifier,"; fi
            shift 2
        done
        if [ -n "$modifier" ]; then modifier="[$modifier]"; fi
    else
        until [ -z "$1" ]; do
            case $1 in
                axis)
                    if [ "$2" = "x" ]; then modifier="1"; fi
                    if [ "$2" = "z" ]; then modifier="2"; fi
                    ;;
                half)
                    case $block in
                        *door)
                            modifier="8"
                            if [ "$4" = "right" ]; then
                                modifier="9"
                                shift 2
                            fi
                            ;;
                        *stairs) modifier="$(($modifier + 4))";;
                        *trapdoor) modifier="$(($modifier + 4))";;
                    esac
                    ;;
                hollow) return;;
                level) modifier="$2";;
                type)
                    if [[ $block == *slab ]]; then
                        modifier="$(($modifier + 8))"
                    fi
                    ;;
            esac
            shift 2
        done
    fi

    echo "$modifier"
}


getBlockValue () {
    block="$1"
    modifier=""
    shift

    # getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true
    # getBlockValue oak_door facing east half upper hinge right
    # getBlockValue wall_torch facing west
    # getBlockValue torch
    # getBlockValue birch stairs facing west shape outer_left

    # convert block name if Bedrock Edition
    if [ $EDITION = "bedrock" ]; then
        case $block in
            acacia_log) block="log2";;
            birch_planks)
                block="planks"
                modifier="2"
                ;;
            bricks) block="brick_block";;
            brick_slab)
                block="stone_slab"
                modifier="4"
                ;;
            dark_oak_planks)
                block="planks"
                modifier="5"
                ;;
            dark_oak_slab)
                block="wooden_slab"
                modifier="5"
                ;;
            oak_door) block="wooden_door";;
            oak_fence) block="fence";;
            oak_planks) block="planks";;
            oak_slab) 
                block="wooden_slab"
                if [ "$2" = "double" ]; then
                    block="$2_$block"
                    shift 2
                fi
                ;;
            oak_trapdoor) block="wooden_trapdoor";;
            polished_andesite)
                block="stone"
                modifier="6"
                ;;
            smooth_quartz)
                block="quartz_block"
                modifier="3"
                ;;
            stone_bricks)
                block="double_stone_slab"
                modifier="5"
                ;;
            stone_brick_slab)
                block="stone_slab"
                modifier="5"
                ;;
            wall_torch) block="torch";;
        esac
    fi

    # calculate modifier
    if [ $EDITION = "java" ]; then
        modifier="$(getBlockModifier $block $@)"
    else
        temp="$(getBlockModifier $block $@)"
        if [ -n "$temp" ]; then modifier="$(($modifier + $(getBlockModifier $block $@)))"; fi
        if [ -n "$modifier" ]; then modifier=" $modifier"; fi
    fi

    echo "$block$modifier"
}


createBlock () {
    case $ORIENTATION in
        north|south) 
            echo "setblock $(getOrientX $1) $(($Y + $2)) $(getOrientZ $3) $4"
            ;;
        west|east)
            echo "setblock $(getOrientX $3) $(($Y + $2)) $(getOrientZ $1) $4"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}


createFill () {
    case $ORIENTATION in
        north|south) 
            echo "fill $(getOrientX $1) $(($Y + $2)) $(getOrientZ $3) $(getOrientX $4) $(($Y + $5)) $(getOrientZ $6) $7"
            ;;
        west|east)
            echo "fill $(getOrientX $3) $(($Y + $2)) $(getOrientZ $1) $(getOrientX $6) $(($Y + $5)) $(getOrientZ $4) $7"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}

shiftStartPosition () {
	# shift start position by 1 block back, necessary to provide space for enclosure
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
		./Subfunctions/createEnclosure.sh -u $(getOrientX $minLW) -v $(($Y + $minY)) -w $(getOrientZ $minCW) -x $(getOrientX $maxLW) -y $(($Y + $maxY)) -z $(getOrientZ $maxCW) -g $Y -b "$(getBlockValue smooth_quartz)" -s "$(getBlockValue smooth_quartz)" -r "$(getBlockValue glowstone)" -o "$ORIENTATION"
	fi
    printComment "Clear Area"
    createFill $minLW 0 $minCW $maxLW $maxY $maxCW "$(getBlockValue air)"
    printComment ""
}


printComment "Create XP Farm at position $X/$Y/$Z facing $ORIENTATION"
printComment ""
prepareArea

if [ "$DELETE" = "TRUE" ]; then exit 0; fi


printComment "Finished"
printComment ""
