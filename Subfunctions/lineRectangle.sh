#!/bin/sh

#  lineRectangle.sh
#
#  Line (walls, ceiling & floor) an area between two points with a given block type.
#  An offset can be set to change the effected area.
#
#  Created by fex on 09.10.18.
#  

X1=""
Y1=""
Z1=""
X2=""
Y2=""
Z2=""
BLOCK="air"
OFFSET="0"

# Read parameters
# u: = p1.x coordinate (east(+) <-> west(-))
# v: = p1.y coordinate (up(+) <-> down(-))
# w: = p1.z coordinate (south(+) <-> north(-))
# x: = p2.x coordinate (east(+) <-> west(-))
# y: = p2.y coordinate (up(+) <-> down(-))
# z: = p2.z coordinate (south(+) <-> north(-))
# <b>: = fill material, default is air
# <o>: = offset, default is 0
USAGE="Usage: $0 [-u first x_coord] [-v first y_coord] [-w first z_coord] [-x second x_coord] [-y second y_coord] [-z second z_coord] [-b block type of the fill material] [-o optional offset]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":u:v:w:x:y:z:b:o:" VALUE "$@" ; do
    case "$VALUE" in
        u) X1="$OPTARG";;
        v) Y1="$OPTARG";;
        w) Z1="$OPTARG";;
        x) X2="$OPTARG";;
        y) Y2="$OPTARG";;
        z) Z2="$OPTARG";;
        b) BLOCK="$OPTARG";;
        o) OFFSET="$OPTARG";;
        :) echo "$USAGE"; exit 1;;
        ?)echo "Unknown flag -$OPTARG detected."; echo "$USAGE"; exit 1
    esac
done

# Verify parameters
if [ "$X1" = "" ]; then echo "First x coordinate missing"; exit 1; fi
if [ "$Y1" = "" ]; then echo "First y coordinate missing"; exit 1; fi
if [ "$Z1" = "" ]; then echo "First z coordinate missing"; exit 1; fi
if [ "$X2" = "" ]; then echo "Second x coordinate missing"; exit 1; fi
if [ "$Y2" = "" ]; then echo "Second y coordinate missing"; exit 1; fi
if [ "$Z2" = "" ]; then echo "Second z coordinate missing"; exit 1; fi

# Establish that the first value is smaller than the second
if [ "$X1" -gt "$X2" ]; then temp=$X2; X2=$X1; X1=$temp; fi
if [ "$Y1" -gt "$Y2" ]; then temp=$Y2; Y2=$Y1; Y1=$temp; fi
if [ "$Z1" -gt "$Z2" ]; then temp=$Z2; Z2=$Z1; Z1=$temp; fi

# start high, end low to avoid trouble with falling blocks over the affected area
# north wall
echo "fill $(($X1 + $OFFSET)) $(($Y2 - $OFFSET)) $(($Z1 + $OFFSET)) $(($X1 + $OFFSET)) $(($Y1 + $OFFSET)) $(($Z2 - $OFFSET)) $BLOCK"
# south wall
echo "fill $(($X2 - $OFFSET)) $(($Y2 - $OFFSET)) $(($Z1 + $OFFSET)) $(($X2 - $OFFSET)) $(($Y1 + $OFFSET)) $(($Z2 - $OFFSET)) $BLOCK"
# west wall
echo "fill $(($X1 + $OFFSET)) $(($Y2 - $OFFSET)) $(($Z1 + $OFFSET)) $(($X2 - $OFFSET)) $(($Y1 + $OFFSET)) $(($Z1 + $OFFSET)) $BLOCK"
# east wall
echo "fill $(($X1 + $OFFSET)) $(($Y2 - $OFFSET)) $(($Z2 - $OFFSET)) $(($X2 - $OFFSET)) $(($Y1 + $OFFSET)) $(($Z2 - $OFFSET)) $BLOCK"
# ceiling
echo "fill $(($X1 + $OFFSET)) $(($Y2 - $OFFSET)) $(($Z1 + $OFFSET)) $(($X2 - $OFFSET)) $(($Y2 - $OFFSET)) $(($Z2 - $OFFSET)) $BLOCK"
# floor
echo "fill $(($X1 + $OFFSET)) $(($Y1 + $OFFSET)) $(($Z1 + $OFFSET)) $(($X2 - $OFFSET)) $(($Y1 + $OFFSET)) $(($Z2 - $OFFSET)) $BLOCK"

# needed to execute the last command
echo""
