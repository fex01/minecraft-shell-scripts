#!/bin/sh

#  createEnclosure.sh
#
# Will enclose a given area from all sides.
# Optional param g can be set to define a ground level higher than the
# enclosures bottom (if your structure goes below ground level this makes sure
# you have solid ground)
# 
#
#  Created by fex on 19.02.2022.
#  

X1=""
Y1=""
Z1=""
X2=""
Y2=""
Z2=""
GROUNDLEVEL=""
BOTTOMBLOCK="smooth_quartz"
SIDEBLOCK="smooth_quartz"
ROOFBLOCK="glowstone"

# Read parameters
# u: = p1.x coordinate (east(+) <-> west(-))
# v: = p1.y coordinate (up <-> down)
# w: = p1.z coordinate (south(+) <-> north(-))
# x: = p2.x coordinate (east(+) <-> west(-))
# y: = p2.y coordinate (up <-> down)
# z: = p2.z coordinate (south(+) <-> north(-))
# <g>: = groundlevel, default is min(v, y)
USAGE="Usage: $0 [-u first x_coord] [-v first y_coord] [-w first z_coord] [-x second x_coord] [-y second y_coord] [-z second z_coord] [-g (optional) raised groundlevel (in between v & y)]"
# Start processing options at index 1.
OPTIND=1
# OPTERR=1
while getopts ":u:v:w:x:y:z:g:" VALUE "$@" ; do
    case "$VALUE" in
        u) X1="$OPTARG";;
        v) Y1="$OPTARG";;
        w) Z1="$OPTARG";;
        x) X2="$OPTARG";;
        y) Y2="$OPTARG";;
        z) Z2="$OPTARG";;
        g) GROUNDLEVEL="$OPTARG";;
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

# Set / verify groundlevel
if [ "$GROUNDLEVEL" = "" ]; then GROUNDLEVEL=$Y1; fi
if [  "$GROUNDLEVEL" -lt "$Y1" -o "$GROUNDLEVEL" -gt "$Y2" ]; then 
	echo "Optional groundlevel g musst be between first and second y value (v, y)"
	exit 1
fi

echo "say Create Enclosure"
# start high, end low to avoid trouble with falling blocks over the affected area
# north wall
echo "fill $X1 $Y2 $Z1 $X1 $Y1 $Z2 $SIDEBLOCK"
# south wall
echo "fill $X2 $Y2 $Z1 $X2 $Y1 $Z2 $SIDEBLOCK"
# west wall
echo "fill $X1 $Y2 $Z1 $X2 $Y1 $Z1 $SIDEBLOCK"
# east wall
echo "fill $X1 $Y2 $Z2 $X2 $Y1 $Z2 $SIDEBLOCK"
# ceiling without sides
echo "fill $(($X1 + 1)) $Y2 $(($Z1 + 1)) $(($X2 - 1)) $Y2 $(($Z2 - 1)) $ROOFBLOCK"
# floor without sides
echo "fill $(($X1 + 1)) $Y1 $(($Z1 + 1)) $(($X2 - 1)) $GROUNDLEVEL $(($Z2 - 1)) $BOTTOMBLOCK"

# needed to execute the last command
echo""
