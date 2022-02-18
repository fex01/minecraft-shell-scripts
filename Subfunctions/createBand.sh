#!/bin/sh

#  createBand.sh
#
#  Lines an horizontale rectangle with a given block type.
#  An offset can be set to change the effected area.
#
#  Created by fex on 09.10.18.
#  

X1=""
Y=""
Z1=""
X2=""
Z2=""
BLOCK="air"
OFFSET="0"

# Read parameters
# u: = p1.x coordinate (east <-> west)
# w: = p1.z coordinate (south <-> north)
# x: = p2.x coordinate (east <-> west)
# z: = p2.z coordinate (south <-> north)
# y: = height (up <-> down)
# <b>: = fill material, default is air
# <o>: = offset, default is 0
USAGE="Usage: $0 [-u first x_coord] [-w first z_coord] [-x second x_coord] [-z second z_coord] [-y height] [-b block type of the fill material] [-o optional offset]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":u:v:w:x:y:z:b:o:" VALUE "$@" ; do
    case "$VALUE" in
        u) X1="$OPTARG";;
        w) Z1="$OPTARG";;
        x) X2="$OPTARG";;
        y) Y="$OPTARG";;
        z) Z2="$OPTARG";;
        b) BLOCK="$OPTARG";;
        o) OFFSET="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X1" = "" ]; then echo "First x coordinate missing"; exit 1; fi
if [ "$Z1" = "" ]; then echo "First z coordinate missing"; exit 1; fi
if [ "$X2" = "" ]; then echo "Second x coordinate missing"; exit 1; fi
if [ "$Z2" = "" ]; then echo "Second z coordinate missing"; exit 1; fi
if [ "$Y" = "" ]; then echo "Second y coordinate missing"; exit 1; fi

# Establish that the first value is smaller than the second
if [ "$X1" -gt "$X2" ]; then temp=$X2; X2=$X1; X1=$temp; fi
if [ "$Z1" -gt "$Z2" ]; then temp=$Z2; Z2=$Z1; Z1=$temp; fi


for x in $(seq $(($X2 - $OFFSET)) $(($X1 + $OFFSET))); do
    echo "setblock $x $Y $(($Z1 + $OFFSET)) $BLOCK"
    echo "setblock $x $Y $(($Z2 - $OFFSET)) $BLOCK"
done

for z in $(seq $(($Z2 - $OFFSET - 1)) $(($Z1 + $OFFSET + 1))); do
    echo "setblock $(($X1 + $OFFSET)) $Y $z $BLOCK"
    echo "setblock $(($X2 - $OFFSET)) $Y $z $BLOCK"
done
echo""
