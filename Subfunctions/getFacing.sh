#!/bin/sh

# getFacing.sh
#
# Returns the correct facing modifier dependent on block type (optional), block 
# facing, structure orientation and Minecraft edition (java, bedrock).
# 
#
#  Created by fex on 20.02.2022.
#  

BLOCK=""
FACING=""
ORIENTATION="south"
EDITION="bedrock"

# Read parameters
# <b>: = (optional) block type
# f: = block facing (south, west, north or east)
# <o>: = (optional) orientation (south, west, north or east), default is south
# <e>: = (optional) Minecraft edition (java, bedrock), default is bedrock
USAGE="Usage: $0 [-b (optional) block type] [-f block facing] [-o structure orientation] [-e Minecraft edition (java, bedrock)]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":b:f:o:e:" VALUE "$@" ; do
    case "$VALUE" in
        b) BLOCK="$OPTARG";;
        f) FACING="$OPTARG";;
        o) ORIENTATION="$OPTARG";;
        e) EDITION="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$FACING" != "south" ] && [ "$FACING" != "west" ] && [ "$FACING" != "north" ] && [ "$FACING" != "east" ]
then
    echo "BLOCK FACING (-f) must be south, west, north or east."
    exit 1
fi
if [ "$ORIENTATION" != "south" ] && [ "$ORIENTATION" != "west" ] && [ "$ORIENTATION" != "north" ] && [ "$ORIENTATION" != "east" ]
then
    echo "ORIENTATION (-o) must be south, west, north or east."
    exit 1
fi
if [ "$EDITION" != "java" ] && [ "$EDITION" != "bedrock" ] 
then 
    echo "EDITION (-e) must be java or bedrock"
    exit 1
fi


orientationArray=(north west south east)
defaultBedrockOrientation=(2 4 3 5)
javaOrientation=(north west south east)
stairsOrientation=(3 1 2 0)
torchOrientation=(4 2 3 1)
trapdoorOrientation=(1 3 0 2)
facing=""

case $BLOCK in
    chest|furnace|hopper|ladder) 
        orientationMapping=("${defaultBedrockOrientation[@]}")
        ;;
    *stairs) orientationMapping=("${stairsOrientation[@]}");;
    torch|lever) orientationMapping=("${torchOrientation[@]}");;
    *trapdoor) orientationMapping=("${trapdoorOrientation[@]}");;
esac

if [ $EDITION = "java" ]; then 
    orientationMapping=("${javaOrientation[@]}")
fi

case $ORIENTATION in
    north) 
        for index in "${!orientationArray[@]}"; do
            if [ "${orientationArray[$index]}" = "$FACING" ]; then
                facing="${orientationMapping[$index]}"
            fi
        done
        ;;
    west) 
        for index in "${!orientationArray[@]}"; do
            if [ "${orientationArray[$index]}" = "$FACING" ]; then
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
            if [ "${orientationArray[$index]}" = "$FACING" ]; then
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
            if [ "${orientationArray[$index]}" = "$FACING" ]; then
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
