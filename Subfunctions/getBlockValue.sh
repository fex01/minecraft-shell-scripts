#!/bin/sh

# Get the correct block string depending on Edition, modifiers & orientation.
# * Java (-j)
# * Bedrock (default)
#
#  Created by fex on 21/02/2022.
#

ORIENTATION="south"
BLOCK=""
EDITION="bedrock"
ARGS=""

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

getBlockModifier () {
    modifier=""
    block="$1"
    shift

    if [ "$1" = "facing" ]; then
        modifier="$(./Subfunctions/getFacing.sh -b $block -f $2 -o $ORIENTATION\
            -e $EDITION)"
        if [ "$EDITION" = "java" ]; then 
            modifier="facing=$modifier"
            # if $3 is not empty
            if [ -n "$3" ]; then modifier="$modifier,"; fi
        fi
        shift 2
    fi

    if [ "$EDITION" = "java" ]; then
        # until $1 is empty
        until [ -z "$1" ]; do
            modifier="$modifier$1=$2"
            # if $3 is not empty
            if [ -n "$3" ]; then modifier="$modifier,"; fi
            shift 2
        done
        if [ -n "$modifier" ]; then modifier="[$modifier]"; fi
    else
        # until $1 is empty
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



block="$1"
modifier=""
shift

# getBlockValue glass_pane \
#   $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) true\
#   $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) true
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
    if [ -n "$temp" ]; then 
        modifier="$(($modifier + $(getBlockModifier $block $@)))"
    fi
    if [ -n "$modifier" ]; then modifier=" $modifier"; fi
fi

echo "$block$modifier"
