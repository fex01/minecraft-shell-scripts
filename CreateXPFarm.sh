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
ORIENTATION="north"
DELETE="FALSE"
BLOCK=""
EDITION="java"
ENCLOSE="FALSE"

# Read parameters
# x: = x coordinate (east(+) <-> west(-))
# y: = y coordinate (up(+) <-> down(-))
# z: = z coordinate (south(+) <-> north(-))
# <o>: = orientation (south, west, north or east), default is south
# <d>: = set flag to delete the structure
# <b>: = set flag to generate output for Bedrock
USAGE="Usage: $0 [-x x_coord] [-y y_coord] [-z z_coord] [-o (optional) orientation] [-d (optional) to delete the structure] [-b (optional) set for Bedrock Edition]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":x:y:z:o:db" VALUE "$@" ; do
    case "$VALUE" in
        x) X="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z="$OPTARG";;
        o) ORIENTATION="$OPTARG";;
        d) DELETE="TRUE"; BLOCK="air";;
        b) EDITION="bedrock";;
        e) ENCLOSE="TRUE";;
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


getFacing () {
    orientationArray=(north west south east)
    chestOrientation=(2 4 3 5)
    furnaceOrientation=(2 4 3 5)
    javaOrientation=(north west south east)
    ladderOrientation=(2 4 3 5)
    stairsOrientation=(3 1 2 0)
    torchOrientation=(4 2 3 1)
    trapdoorOrientation=(1 3 0 2)
    facing=""

    case $1 in
        furnace) orientationMapping=("${furnaceOrientation[@]}");;
        ladder) orientationMapping=("${ladderOrientation[@]}");;
        *stairs) orientationMapping=("${stairsOrientation[@]}");;
        torch) orientationMapping=("${torchOrientation[@]}");;
        *trapdoor) orientationMapping=("${trapdoorOrientation[@]}");;
    esac

    if [ $EDITION = "java" ]; then 
        orientationMapping=("${javaOrientation[@]}")
    fi

    case $ORIENTATION in
        north) 
            for index in "${!orientationArray[@]}"; do
                if [ "${orientationArray[$index]}" = "$2" ]; then
                    facing="${orientationMapping[$index]}"
                fi
            done
            ;;
        west) 
            for index in "${!orientationArray[@]}"; do
                if [ "${orientationArray[$index]}" = "$2" ]; then
                    temp="$(($index + 1))"
                    if [ $temp -gt 3 ]; then
                        temp="$(($temp - 4))"
                    fi
                    facing="${orientationMapping[$temp]}"
                fi
            done
            ;;
        south) 
            for index in "${!orientationArray[@]}"; do
                if [ "${orientationArray[$index]}" = "$2" ]; then
                    temp="$(($index + 2))"
                    if [ $temp -gt 3 ]; then
                        temp="$(($temp - 4))"
                    fi
                    facing="${orientationMapping[$temp]}"
                fi
            done
            ;;
        east) 
            for index in "${!orientationArray[@]}"; do
                if [ "${orientationArray[$index]}" = "$2" ]; then
                    temp="$(($index + 3))"
                    if [ $temp -gt 3 ]; then
                        temp="$(($temp - 4))"
                    fi
                    facing="${orientationMapping[$temp]}"
                fi
            done
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac

    echo "$facing"
}


getBlockModifier () {
    modifier=""
    block="$1"
    shift

    if [ "$1" = "facing" ]; then
        modifier="$(getFacing $block $2)"
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


createVerticalBeam () {
    createFill $1 0 $2 $1 $3 $2 "$(getBlockValue acacia_log)"
}


createLengthwiseBeam () {
    case $ORIENTATION in
        north|south)
            createFill $1 $2 $3 $1 $2 $(($3 + $4)) "$(getBlockValue acacia_log axis z)"
            ;;
        west|east)
            createFill $1 $2 $3 $1 $2 $(($3 + $4)) "$(getBlockValue acacia_log axis x)"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}


createCrossBeam () {
    case $ORIENTATION in
        north|south)
            createFill $1 $2 $3 $(($1 + $4)) $2 $3 "$(getBlockValue acacia_log axis x)"
            ;;
        west|east)
            createFill $1 $2 $3 $(($1 + $4)) $2 $3 "$(getBlockValue acacia_log axis z)"
            ;;
        *) "Orientation must be south, west, north or east."; exit 1
    esac
}

createTorchRing () {
    createBlock $(($1 - 1)) $2 $3 "$(getBlockValue wall_torch facing west)"
    createBlock $1 $2 $(($3 + 1)) "$(getBlockValue wall_torch facing south)"
    createBlock $(($1 + 1)) $2 $3 "$(getBlockValue wall_torch facing east)"
    createBlock $1 $2 $(($3 - 1)) "$(getBlockValue wall_torch facing north)"
}


prepareArea () {
    printComment "Clear Area"
    createFill $minLW 0 $minCW $maxLW $maxY $maxCW "$(getBlockValue air)"
    printComment ""
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
    createFill 11 2 6 11 3 6 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill 11 2 10 11 3 10 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill 11 2 14 11 3 14 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill 11 2 18 11 3 18 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill 11 8 6 11 9 6 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill 11 8 10 11 9 10 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill 11 8 14 11 9 14 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill 11 8 18 11 9 18 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"

    # back
    createFill 9 2 20 7 3 20 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createBlock 3 1 20 "$(getBlockValue oak_door facing north hinge right)"
    createBlock 3 2 20 "$(getBlockValue oak_door facing north half upper hinge right)"
    createBlock -3 1 20 "$(getBlockValue oak_door facing north)"
    createBlock -3 2 20 "$(getBlockValue oak_door facing north half upper)"
    createFill -7 2 20 -9 3 20 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createFill 9 8 20 7 9 20 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createFill 3 8 20 1 9 20 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createFill -1 8 20 -3 9 20 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createFill -7 8 20 -9 9 20 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"

    # right
    createFill -11 2 6 -11 3 6 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill -11 2 10 -11 3 10 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill -11 2 14 -11 3 14 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill -11 2 18 -11 3 18 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill -11 8 6 -11 9 6 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill -11 8 10 -11 9 10 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill -11 8 14 -11 9 14 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"
    createFill -11 8 18 -11 9 18 "$(getBlockValue glass_pane $(getFacing "" north) true $(getFacing "" south) true)"

    # front
    createFill 3 2 4 3 3 4 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createBlock 0 1 4 "$(getBlockValue oak_door facing south)"
    createBlock 0 2 4 "$(getBlockValue oak_door facing south half upper)"
    createFill -3 2 4 -3 3 4 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createFill -7 2 4 -9 3 4 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createFill 9 8 4 7 9 4 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createFill 2 8 4 -2 9 4 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"
    createFill -7 8 4 -9 9 4 "$(getBlockValue glass_pane $(getFacing "" east) true $(getFacing "" west) true)"

    # indoor
    createBlock 2 1 12 "$(getBlockValue oak_door facing east)"
    createBlock 2 2 12 "$(getBlockValue oak_door facing east half upper)"
    createBlock 2 1 13 "$(getBlockValue oak_door facing east hinge right)"
    createBlock 2 2 13 "$(getBlockValue oak_door facing east half upper hinge right)"
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
    createFill -6 6 9 -6 6 10 "$(getBlockValue birch_stairs facing east half top)"
    createBlock -4 1 8 "$(getBlockValue birch_stairs facing west shape outer_left)"
    createFill -4 1 9 -4 1 10 "$(getBlockValue birch_stairs facing west)"
    createBlock -4 1 11 "$(getBlockValue birch_stairs facing west shape outer_right)"
    createFill -5 1 9 -5 1 10 "$(getBlockValue oak_planks)"
    createFill -5 2 9 -5 2 10 "$(getBlockValue birch_stairs facing west)"
    createFill -6 1 9 -6 1 10 "$(getBlockValue oak_planks)"
    createFill -6 2 9 -6 2 10 "$(getBlockValue birch_planks)"
    createFill -7 1 9 -7 2 10 "$(getBlockValue oak_planks)"
    createFill -7 3 9 -7 3 10 "$(getBlockValue birch_stairs facing west)"
    createFill -8 4 9 -8 4 10 "$(getBlockValue birch_stairs facing west)"
    createBlock -9 4 9 "$(getBlockValue birch_stairs facing south shape inner_left half top)"
    createBlock -10 4 9 "$(getBlockValue birch_stairs facing south shape inner_right half top)"
    createBlock -9 4 10 "$(getBlockValue birch_stairs facing north shape inner_right half top)"
    createBlock -10 4 10 "$(getBlockValue birch_stairs facing north shape inner_left half top)"
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


printComment "Create XP Farm at position $X/$Y/$Z facing $ORIENTATION"
printComment ""
prepareArea

if [ "$DELETE" = "TRUE" ]; then exit 0; fi

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
echo ""
