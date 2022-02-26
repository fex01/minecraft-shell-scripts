#!/bin/sh

# Get the correct block string depending on Edition, modifiers & orientation.
#
# Examples:
# ./Subfunctions/getBlockValue -b glass_pane -o $ORIENTATION -e $EDITION \
#   -a $(./Subfunctions/getFacing.sh -f east -o $ORIENTATION -e $EDITION) true \
#   $(./Subfunctions/getFacing.sh -f west -o $ORIENTATION -e $EDITION) true
# ./Subfunctions/getBlockValue -b oak_door -a facing east half upper hinge right
# ./Subfunctions/getBlockValue -b wall_torch -o $ORIENTATION -a facing west 
# ./Subfunctions/getBlockValue -b torch -o $ORIENTATION -e $EDITION
# ./Subfunctions/getBlockValue -b birch_stairs \
#   -o $ORIENTATION -e $EDITION \
#   -a facing west shape outer_left
#
#  Created by fex on 21/02/2022.
#

BLOCK=""
ORIENTATION="south"
EDITION="bedrock"
ARGS=()
MODIFIER=""

# Read parameters
# b: = block name (according to Java Edition)
# <a>: = (optional) one to multiple block modifiers
# <o>: = (optional) orientation (south, west, north or east), default is south
# <e>: = (optional) Minecraft edition (java, bedrock), default is bedrock
USAGE="Usage: $0 [-b block name (according to Java Edition)]
    [-a (optional) array of block modifiers]
    [-o (optional) orientation (south, west, north or east), default is south]
    [-e (optional) Minecraft edition (java, bedrock), default is bedrock]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":b:o:e:a:" VALUE "$@" ; do
    case "$VALUE" in
        b) BLOCK="$OPTARG";;
        o) ORIENTATION="$OPTARG";;
        e) EDITION="$OPTARG";;
        a) ARGS=( "${@:$((OPTIND - 1))}" );;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done


# Verify parameters
if [ "$BLOCK" = "" ]; then echo "block name (-b) missing"; exit 1; fi
if ! [[ "$BLOCK" =~ ^[a-z_]+$ ]]
then 
    echo "\"$BLOCK\" (-b) is not a valid block name"
    exit 1
fi
if [ "$ORIENTATION" != "south" ] && [ "$ORIENTATION" != "west" ] &&\
    [ "$ORIENTATION" != "north" ] && [ "$ORIENTATION" != "east" ]
then
    echo "Orientation must be unset (defaults to south), south, west, north or east."
    exit 1
fi
if [ "$EDITION" != "java" ] && [ "$EDITION" != "bedrock" ]
then
    echo "Edition (-e) must be unset (defaults to bedrock), java or bedrock"
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

    # change rail modifier depending on $ORIENTATION
    if [ "$1" = shape ]; then
        temp="${2%_*}"
        if [ "$temp" != ascending]; then 
            temp="$(./Subfunctions/getFacing.sh -f $temp)"
        fi
        2="${temp}_$(./Subfunctions/getFacing.sh -f ${2#*_})"
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
                        *) echo "Unknown combination block=$block," \
                            "modifier=half"
                            exit 1
                    esac
                    ;;
                hollow) return;;
                level) modifier="$2";;
                powered) modifier="$(($modifier + 8))";;
                shape)
                    case $2 in
                        north_south) modifier="0";;
                        east_west) modifier="1";;
                        ascending_east) modifier="2";;
                        ascending_west) modifier="3";;
                        ascending_north) modifier="4";;
                        ascending_south) modifier="5";;
                        south_east) modifier="6";;
                        south_west) modifier="7";;
                        north_west) modifier="8";;
                        north_east) modifier="9";;
                        *) echo "Unknown combination block=$block, $1=$2"
                            exit 1
                    esac
                    ;;
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


# convert block name if Bedrock Edition
if [ $EDITION = "bedrock" ]; then
    case $BLOCK in
        acacia_log) BLOCK="log2";;
        birch_planks)
            BLOCK="planks"
            MODIFIER="2"
            ;;
        bricks) BLOCK="brick_block";;
        brick_slab)
            BLOCK="stone_slab"
            MODIFIER="4"
            ;;
        dark_oak_planks)
            BLOCK="planks"
            MODIFIER="5"
            ;;
        dark_oak_slab)
            BLOCK="wooden_slab"
            MODIFIER="5"
            ;;
        oak_door) BLOCK="wooden_door";;
        oak_fence) BLOCK="fence";;
        oak_planks) BLOCK="planks";;
        oak_slab) 
            BLOCK="wooden_slab"
            if [ ${#ARGS[@]} -ge 2 ] && [ "${ARGS[1]}" = "double" ]; then
                BLOCK="${ARGS[1]}_$BLOCK"
                ARGS=("${ARGS[@]:2}")
            fi
            ;;
        oak_trapdoor) BLOCK="wooden_trapdoor";;
        polished_andesite)
            BLOCK="stone"
            MODIFIER="6"
            ;;
        redstone_torch)
            if [ ${#ARGS[@]} -ge 2 ] && [ "${ARGS[1]}" = "false" ]; then
                BLOCK="unlit_redstone_torch"
                ARGS=("${ARGS[@]:2}")
            fi
            MODIFIER="5"
            ;;
        smooth_quartz)
            BLOCK="quartz_block"
            MODIFIER="3"
            ;;
        stone_bricks)
            BLOCK="double_stone_slab"
            MODIFIER="5"
            ;;
        stone_brick_slab)
            BLOCK="stone_slab"
            MODIFIER="5"
            ;;
        wall_torch) BLOCK="torch";;
    esac
fi


# calculate modifier
if [ $EDITION = "java" ]; then
    MODIFIER="$(getBlockModifier $BLOCK ${ARGS[@]})"
else
    temp="$(getBlockModifier $BLOCK ${ARGS[@]})"
    if [ -n "$temp" ]; then 
        MODIFIER="$(($MODIFIER + $(getBlockModifier $BLOCK ${ARGS[@]})))"
    fi
    if [ -n "$MODIFIER" ]; then MODIFIER=" $MODIFIER"; fi
fi

echo "$BLOCK$MODIFIER"
